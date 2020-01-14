# frozen_string_literal: true

require 'method_source'
require 'libis/tools/extend/hash'
require 'libis/tools/extend/array'

module Teneo
  module DataModel

    class SeedLoader
      attr_reader :base_dir, :prompt, :tty, :quiet

      def initialize(base_dir, tty: true, quiet: false)
        @base_dir = base_dir
        @tty = tty
        @quiet = quiet
        @prompt = if quiet
                    NoPrompt.new
                  elsif tty
                    require 'tty-prompt'
                    TTY::Prompt.new
                  else
                    StdoutPrompt.new('')
                  end
        load
      end

      protected

      class NoPrompt

        def initialize(*args)
        end

        def method_missing(name, *args)
        end

      end

      class StdoutPrompt < NoPrompt

        def initialize(mask, *args)
          @mask = mask
        end

        def update(opts = {})
          puts @mask + opts.values.join(' ')
        end

        def error(msg)
          puts "ERROR: #{msg}"
        end

      end

      def load
        load_storage_types
        load_data :format
        load_data :access_right
        load_data :retention_policy
        load_data :representation_info
        load_data :producer
        load_data :material_flow
        load_data :converter
        load_data :organization
        load_data :user
        load_data :membership
        load_data :ingest_agreement
        load_data :task
        load_data :stage_workflow
        load_data :ingest_workflow
        load_data :ingest_model
        load_data :package
      end

      def create_spinner(klass_name)
        if quiet
          NoPrompt.new
        elsif tty
          require 'tty-spinner'
          TTY::Spinner::new("[:spinner] Loading #{klass_name}(s) :file :name", interval: 4)
        else
          StdoutPrompt.new("Loading #{klass_name}(s) ")
        end
      end

      def string_to_class(klass_name)
        "Teneo::DataModel::#{klass_name.to_s.classify}".constantize
      end

      def load_data(klass_name)
        klass = string_to_class(klass_name)
        begin
          file_list = Dir.children(base_dir).select { |f| f =~ /\.#{klass_name}\.yml$/ }.sort
        rescue Errno::ENOENT
          return
        rescue StandardError => e
          puts "WARNING: #{e.class.name} - #{e.message}"
          return
        end
        return unless file_list.size > 0
        spinner = create_spinner(klass_name)
        spinner.auto_spin
        spinner.update(file: '...', name: '')
        spinner.start
        file_list.each do |filename|
          spinner.update(file: "from '#{filename}'", name: '')
          path = File.join(base_dir, filename)
          data = YAML.load_file(path)
          case data
          when Array
            data.each do |x|
              x.deep_symbolize_keys!
              (n = x[:name] || x[x.keys.first]) && spinner.update(name: "object '#{n}'")
              klass.from_hash(x)
              # spinner.update(name: '')
            end
          when Hash
            x = data.deep_symbolize_keys
            (n = x[:name] || x[x.keys.first]) && spinner.update(name: "object '#{n}'")
            klass.from_hash(x)
          else
            prompt.error "Illegal file content: 'path' - either Array or Hash expected."
          end
          # spinner.update(file: '...')
        end
        spinner.update(file: '- Done', name: '!')
        spinner.success
      end

      def load_storage_types
        class_list = Teneo::DataModel::StorageDriver::Base.drivers
        return unless class_list.size > 0
        spinner = create_spinner('storage driver')
        spinner.auto_spin
        spinner.update(file: '...', name: '')
        spinner.start
        spinner.update(file: "from driver classes", name: '')
        class_list.map do |driver|
          spinner.update(name: "object '#{driver.protocol}'")
          info = {
              protocol: driver.protocol,
              driver_class: driver.name,
              description: driver.description
          }
          initializer = driver.instance_method(:initialize)
          defaults = initializer.source.match(/^\s*def\s+initialize\s*\(\s*(.*)\s*\)/)[1].gsub("\n", '')
          defaults = JSON.parse Hash[defaults.scan(/\s*(\w+):\s*([^,]+)(?:,|$)/)].to_s.
              gsub('=>', ' : ').gsub(/\\\"|'/,'')
          r = /^\s*#\s*@param\s+\[([^\]]*)\]\s+(\w+)\s+(.*)$/
          info[:parameters] = initializer.comment.scan(r).map do |datatype, name, description|
            {
                name: name,
                data_type: datatype,
                default: defaults[name],
                description: description
            }
          end.each_with_object({}) do |info, hash|
            hash[info.delete(:name)] = info
          end
          info = info.recursive_cleanup
          # ap info
          Teneo::DataModel::StorageType.from_hash(info)
        end
        spinner.update(file: '- Done', name: '!')
        spinner.success
      end

    end

  end
end