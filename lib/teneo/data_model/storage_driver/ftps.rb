# frozen_string_literal: true
require_relative 'base'

require 'net/ftp'
require 'tempfile'

module Teneo
  module DataModel
    module StorageDriver

      class Ftps < Base

        protocol 'FTPS'
        description 'FTPS server'
        local? false

        class Dir < Base::Dir
          def driver_path
            @path
          end
        end

        class File < Base::File

          class Cleaner
            def initialize(tmpfile)
              @pid = Process.pid
              @tmpfile = tmpfile
            end

            def call(*_args)
              return if @pid != Process.pid
              ::File.delete(@tmpfile)
            rescue Errno::ENOENT
              # ignore
            end
          end

          def initialize(path:, driver:)
            ext = ::File.extname(path)
            name = ::File.basename(path, ext)
            temp_path = ::Dir::Tmpname.create(["#{driver.name}-#{name}", ext]) {}
            ObjectSpace.define_finalizer(self, Cleaner.new(temp_path))
            super path: temp_path, driver: driver
            @remote_path = path
            @dirty = false
            @localized = false
          end

          # @return [String (frozen)]
          def driver_path
            @remote_path
          end

          # @param [String] new_name
          # @return [String] new driver path
          def rename(new_name)
            @remote_path = do_rename(new_name)
          end

          # @param [String] new_dir
          # @return [String] new driver path
          def move(new_dir)
            @remote_path = do_move(new_dir)
          end

          # @return [String, Object]
          def read
            localize
            super
          end

          # @param [String] data
          def write(data = nil)
            @dirty = true
            super
          end

          # @param [String] data
          def append(data = nil)
            localize
            @dirty = true
            super
          end

          def close
            save_remote if @dirty
          end

          protected

          attr_reader :remote_path, :service

          def localize
            return nil if @localized
            #noinspection RubyResolve
            raise Errno::ENOENT unless exist?
            @driver.download(remote: @remote_path, local: @path)
            @localized = true
          end

          def save_remote
            @driver.upload(local: @path, remote: @remote_path)
            @dirty = false
            @localized = false
            !@localized
          end

        end

        # Create FTPS driver
        # @param [String] host name or ip adress of the server
        # @param [Integer] port (21) number of the port the server is listening on
        # @param [String] user login name
        # @param [String] password login password
        # @param [String] location remote root path
        # @param [Boolean] binary (true) default transfer mode
        def initialize(host:, port: 21, user:, password:, location:, binary: true)
          @host = host
          @port = port
          @user = user
          @password = password
          @root = location
          @binary = binary
          connect
        end

        # Create a directory
        # @param [String] path
        # @return [Teneo::DataModel::StorageDriver::Ftps::Dir, FalseClass]
        def mkdir(path)
          ftp_service { |conn| conn.mkdir(abspath(path)) }
          super
        end

        # Get a Dir object for a given path. Path is not required to exist
        # @param [String] path
        # @return [Teneo::DataModel::StorageDriver::Ftps::Dir]
        def dir(path = nil)
          path ||= ::File::SEPARATOR
          Ftps::Dir.new(path: safepath(path), driver: self)
        end

        # Get a File object for a given path. Path is not required to exist
        # @param [String] path
        # @return [Teneo::DataModel::StorageDriver::Ftps::File]
        def file(path)
          Ftps::File.new(path: safepath(path), driver: self)
        end

        # Test if directory exists
        # @param [String] path
        # @return [TrueClass, FalseClass]
        def dir_exist?(path)
          ftp_service do |conn|
            conn.chdir(abspath(path))
            conn.chdir('/')
            true
          end
        rescue ::Net::FTPError
          return false
        end

        # Test if file exists
        # @param [String] path
        # @return [TrueClass, FalseClass]
        def file_exist?(path)
          is_file?(path)
        end

        # Test if file or directory exists
        # @param [String] path
        # @return [TrueClass, FalseClass]
        def exist?(path)
          file_exist?(path) || dir_exist?(path)
        end

        # Check if remote path is a file (or a directory)
        # @param [String] path
        # @return [TrueClass, FalseClass] true if file, false otherwise
        def is_file?(path)
          ftp_service do |conn|
            conn.size(abspath(path)).is_a?(Numeric) ? true : false
          end
        rescue ::Net::FTPError
          false
        end

        # Download a file
        # @param [String] remote remote file path
        # @param [String] local local file path
        # @return [FalseClass, TrueClass]
        def download(remote:, local:)
          ftp_service do |conn|
            conn.getbinaryfile(abspath(remote), local)
          end
          true
        rescue ::Net::FTPError
          false
        end

        # Upload a file
        # @param [String] local local file path
        # @param [String] remote remote file path
        # @return [FalseClass, TrueClass]
        def upload(local:, remote:)
          ftp_service do |conn|
            conn.putbinaryfile(local, abspath(remote))
          end
          true
        rescue ::Net::FTPError
          false
        end

        # Delete a file
        # @param [String] path remote file or directory path
        # @return [FalseClass, TrueClass]
        def delete(path)
          ftp_service do |conn|
            is_file?(path) ? conn.delete(abspath(path)) : conn.rmdir(abspath(path))
          end
          true
        rescue ::Net::FTPError
          false
        end

        # Delete a directory
        # @param [String] path remote directory
        # @return [FalseClass, TrueClass]
        def del_tree(path)
          entries(path).map { |e| del_tree(e.driver_path) } unless is_file?(path)
          delete(path)
        end

        # get last modification time
        # @param [String] path
        # @return [NilClass, Time] file modification time
        def mtime(path)
          ftp_service do |conn|
            conn.mtime(abspath(path))
          end
        rescue ::Net::FTPError
          nil
        end

        # rename a file or folder
        # @param [String] from_path
        # @param [String] to_path
        # @return [NilClass, String] new relative name
        def rename(from_path, to_path)
          ftp_service do |conn|
            conn.rename(abspath(from_path), abspath(to_path))
          end
          safepath(to_path)
        rescue ::Net::FTPError
          nil
        end

        # get file size
        # @param [String] path
        # @return [NilClass, Integer] file size
        def size(path)
          ftp_service do |conn|
            conn.size(abspath(path))
          end
        rescue ::Net::FTPError
          nil
        end

        protected

        # @param [String] path
        # @param [Proc] block
        # @return [Array<Teneo::DataModel::StorageDriver::Ftps::File, Teneo::DataModel::StorageDriver::Ftps::Dir>]
        def dir_children(path, &block)
          ftp_service do |conn|
            conn.nlst(abspath(path)).map do |e|
              block.call relpath(e)
            end
          end
        end

        # @return [Net::FTP]
        # def ftp_service
        #   @connection
        # end

        # Tries to execute ftp commands; reconnects and tries again if connection timed out
        def ftp_service
          yield @connection
        rescue Errno::ETIMEDOUT, Net::FTPConnectionError, Errno::EPIPE
          disconnect
          connect
          yield @connection
        end

        # Connect to FTP server
        # @return [Net::FTP]
        def connect
          connection_params = {
              port: @port,
              ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
              passive: true,
              username: @user,
              password: @password,
              open_timeout: 10.0,
          }
          @connection = Net::FTP.new(@host, connection_params)
        end

        # Disconnect from FTP server
        def disconnect
          ftp_service do |conn|
            conn.close
          end
        rescue ::Net::FTPError
          # do nothing
        end

      end

    end
  end
end
