# frozen_string_literal: true
require 'pathname'
require 'fileutils'

module Teneo
  module DataModel
    module StorageDriver

      class Base

        def self.drivers
          @drivers ||= ObjectSpace.each_object(Class).select { |klass| klass < self }
        end

        def self.protocols
          drivers.map { |klass| klass.protocol }
        end

        def self.driver(protocol)
          drivers.find { |d| d.protocol == protocol }
        end

        def self.protocol(value = nil)
          @protocol = value unless value.nil?
          @protocol
        end

        def self.description(value = nil)
          @description = value unless value.nil?
          @description || ''
        end

        def self.local?(value = nil)
          @local = value unless value.nil?
          @local
        end

        class Entry

          def initialize(path:, driver:)
            @path = path
            @driver = driver
          end

          def driver_path
            @driver.relpath(@path)
          end

          def local_path
            @path
          end

          def exist?
            @driver.exist?(driver_path)
          end

          def local?
            @driver.class.local?
          end

          def protocol
            @driver.class.protocol
          end

          def delete
            @driver.delete(driver_path)
          end

          def mtime
            @driver.mtime(driver_path)
          end

          def rename(new_name)
            @path = do_rename(new_name)
          end

          def do_rename(new_name)
            new_path = ::File.join(::File.dirname(driver_path), ::File.basename(new_name))
            @driver.rename(driver_path, new_path)
          end
          protected :do_rename

          def move(new_dir)
            @path = do_move(new_dir)
          end

          def do_move(new_dir)
            new_path = ::File.join(new_dir, ::File.basename(driver_path))
            new_path = ::File.join(::File.dirname(driver_path), new_path) unless Pathname.new(new_dir).absolute?
            @driver.dir(::File.dirname(new_path)).touch
            @driver.rename(driver_path, new_path)
          end
          protected :do_move

        end

        class Dir < Teneo::DataModel::StorageDriver::Base::Entry

          def file?
            false
          end

          def entries(&block)
            if block_given?
              @driver.entries(driver_path, &block)
            else
              @driver.entries(driver_path)
            end
          end

          def dir(path = '..')
            return self if is_root?
            path = ::File.join(driver_path, path)
            @driver.dir(path)
          end

          def file(path)
            @driver.file(::File.join(driver_path, path))
          end

          def touch
            dir.touch unless is_root?
            @driver.mkdir(driver_path) unless exist?
          end

          def is_root?
            ::File::SEPARATOR == driver_path
          end

        end

        class File < Teneo::DataModel::StorageDriver::Base::Entry

          def file?
            true
          end

          def dir
            @driver.dir(::File.dirname(driver_path))
          end

          def touch
            return nil if exist?
            dir.touch
            write(nil)
          end

          def read
            return false unless exist?
            ::File.open(local_path, 'rb') do |f|
              block_given? ? yield(f) : f.read
            end
          end

          def write(data = nil)
            dir.touch
            ::File.open(local_path, 'wb') do |f|
              block_given? ? yield(f) : f.write(data)
            end
            close
          end

          def append(data = nil)
            dir.touch
            ::File.open(local_path, 'ab') do |f|
              block_given? ? yield(f) : f.write(data)
            end
            close
          end

          def close
            # Do nothing
          end

          def size
            @driver.size(driver_path)
          end

          def copy_to(target)
            case target
            when nil
              return false
            when String
              FileUtils.cp local_path, target
            when Teneo::DataModel::Base::File
              FileUtils.cp local_path, target.local_path
              target.close
            when Teneo::DataModel::Base::Dir
              target = target.file(::File.basename(local_path))
              FileUtils.cp local_path, target.local_path
              target.close
            else
              raise RuntimeError, "target class not supported: #{target.klass}"
            end
            target
          end

          def copy_from(target)
            case target
            when nil
              return false
            when String
              FileUtils.cp target, local_path
              close
            when Teneo::DataModel::Base::File
              FileUtils.cp target.local_path, local_path
              close
            when Teneo::DataModel::Base::Dir
              target = target.file(File.basename(local_path))
              FileUtils.cp target.local_path, local_path
              close
            else
              raise RuntimeError, "target class not supported: #{target.klass}"
            end
            self
          end

        end

        def name
          "#{self.class.name.split('::').last}-#{root.hash.to_s(36)}"
        end

        # Get directory listing
        # @param [String] path
        # @return [Array[<File, Dir>]
        def entries(path = nil)
          path ||= ::File::SEPARATOR
          dir_children(path) do |e|
            if block_given?
              yield e
            else
              self.entry e
            end
          end.cleanup
        end

        # Get a File or Dir object for a given path. Path should exist.
        # @param [String] path
        # @return [nil, Teneo::DataModel::StorageDriver::Nfs::File, Teneo::DataModel::StorageDriver::Nfs::Dir]
        def entry(path)
          return nil unless self.exist?(path)
          self.is_file?(path) ? self.file(path) : self.dir(path)
        end

        def root
          @root.freeze
        end

        def abspath(path)
          ::File.join(@root, safepath(path))
        end

        def relpath(path)
          p = ::File.join(::File::SEPARATOR, safepath(path))
          Pathname(p).relative_path_from(Pathname(@root)).to_s
        rescue ArgumentError
          ::File::SEPARATOR
        end

        def safepath(path)
          ::File.expand_path(::File::SEPARATOR + path, ::File::SEPARATOR)
        end

        # Need to be overwritten

        def mkdir(path)
          exist?(path) ? dir(path) : false
        end

        def dir(path = nil)
          raise NotImplementedError, "Method needs implementation";
        end

        def file(path)
          raise NotImplementedError, "Method needs implementation";
        end

        def exist?(path)
          raise NotImplementedError, "Method needs implementation";
        end

        def is_file?(path)
          raise NotImplementedError, "Method needs implementation";
        end

        def delete(path)
          raise NotImplementedError, "Method needs implementation";
        end

        def del_tree(path)
          raise NotImplementedError, "Method needs implementation";
        end

        def mtime
          raise NotImplementedError, "Method needs implementation";
        end

        def rename(new_name)
          raise NotImplementedError, "Method needs implementation";
        end

        def size
          raise NotImplementedError, "Method needs implementation";
        end

        protected

        def dir_children(path, &block)
          raise NotImplementedError, "Method needs implementation";
        end

        attr_accessor :path

      end

    end
  end
end
