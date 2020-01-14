# frozen_string_literal: true
require 'fileutils'
require 'libis/tools/extend/array'

require_relative 'base'

module Teneo
  module DataModel
    module StorageDriver

      class Nfs < Base

        protocol 'NFS'
        description 'Local disk or mounted network drive'
        local? true

        class Dir < Teneo::DataModel::StorageDriver::Base::Dir
        end

        class File < Teneo::DataModel::StorageDriver::Base::File
        end

        # Create NFS driver
        # @param [String] location the root folder for the file service
        def initialize(location:)
          @root = location
        end

        # Create a directory
        # @param [String] path
        # @return [Teneo::DataModel::StorageDriver::Nfs::Dir, FalseClass]
        def mkdir(path)
          FileUtils.mkdir(abspath(path))
          exist?(path) ? dir(path) : false
        end

        # Get a File or Dir object for a given path. Path should exist.
        # @param [String] path
        # @return [nil, Teneo::DataModel::StorageDriver::Nfs::File, Teneo::DataModel::StorageDriver::Nfs::Dir]
        def entry(path)
          return nil unless exist?(path)
          is_file?(path) ? file(path) : dir(path)
        end

        # Get a Dir object for a given path. Path is not required to exist
        # @param [String] path
        # @return [Teneo::DataModel::StorageDriver::Nfs::Dir]
        def dir(path = nil)
          path ||= ::File::SEPARATOR
          Nfs::Dir.new(path: abspath(path), driver: self)
        end

        # Get a File object for a given path. Path is not required to exist
        # @param [String] path
        # @return [Teneo::DataModel::StorageDriver::Nfs::File]
        def file(path)
          Nfs::File.new(path: abspath(path), driver: self)
        end

        # Test if file exists
        # @param [String] path
        # @return [TrueClass, FalseClass]
        def file_exist?(path)
          exist?(path) && is_file?(path)
        end

        # Test if directory exists
        # @param [String] path
        # @return [TrueClass, FalseClass]
        def dir_exist?(path)
          exist?(path) && !is_file?(path)
        end

        # Test if file or directory exists
        # @param [String] path
        # @return [TrueClass, FalseClass]
        def exist?(path)
          ::File.exist?(abspath(path))
        end

        # Check if remote path is a file (or a directory)
        # @param [String] path
        # @return [TrueClass, FalseClass] true if file, false otherwise
        def is_file?(path)
          ::File.file? abspath(path)
        end

        # Delete a file
        # @param [String] path
        # @return [TrueClass, FalseClass]
        def delete(path)
          return false unless exist?(path)
          FileUtils.rm abspath(path)
          true
        end

        # Delete a directory
        # @param [String] path
        # @return [TrueClass, FalseClass]
        def del_tree(path)
          return false unless exist?(path)
          FileUtils.rmtree abspath(path)
          true
        end

        # get last modification time
        # @param [String] path
        # @return [Time] file modification time
        def mtime(path)
          ::File.new(abspath(path)).mtime
        end

        # rename a file or folder
        # @param [String] from_path
        # @param [String] to_path
        # @return [String] new driver path
        def rename(from_path, to_path)
          ::File.rename(abspath(from_path), abspath(to_path))
          abspath(to_path)
        end

        # get file size
        # @param [String] path
        # @return [Integer] file size
        def size(path)
          ::File.new(abspath(path)).size
        end

        # @param [String] from_path
        # @param [String] to_path
        def symlink(from_path, to_path)
          ::File.symlink(abspath(from_path), abspath(to_path))
        end

        protected

        def dir_children(path, &block)
          ::Dir.children(abspath(path)).map do |e|
            block.call ::File.join(path, e)
          end
        end

      end
    end
  end
end