# frozen_string_literal: true
require 'tty-prompt'
require 'tty-spinner'

module Teneo
  module DataModel

    class SeedLoader
      attr_reader :base_dir, :prompt

      def initialize(base_dir)
        @base_dir = base_dir
        @prompt = TTY::Prompt.new
        load
      end

      private

      def load
        load_data :format
        load_data :access_right
        load_data :retention_policy
        load_data :representation_info
        load_data :producer
        load_data :material_flow
        load_data :converter
        load_data :organization
        load_data :user
        load_data :ingest_agreement
        load_data :ingest_model
        load_data :task
        load_data :stage_workflow
        load_data :ingest_workflow
      end

      def load_data(klass_name)
        klass = "Teneo::DataModel::#{klass_name.to_s.classify}".constantize
        spinner = TTY::Spinner::new("[:spinner] Loading #{klass_name}(s) :file :name", interval: 4)
        spinner.auto_spin
        spinner.update(file: '...', name: '')
        spinner.start
        Dir.children(base_dir).select {|f| f =~ /\.#{klass_name}\.yml$/}.sort.each do |filename|
          spinner.update(file: "from '#{filename}'")
          path = File.join(base_dir, filename)
          data = YAML.load_file(path)
          case data
          when Array
            data.each do |x|
              x.deep_symbolize_keys!
              (n = x[:name] || x[x.keys.first]) && spinner.update(name: "object '#{n}'")
              klass.from_hash(x)
              spinner.update(name: '')
            end
          when Hash
            klass.from_hash(data.deep_symbolize_keys)
          else
            prompt.error "Illegal file content: 'path' - either Array or Hash expected."
          end
          spinner.update(file: '...')
        end
        spinner.update(file: '- Done', name: '!')
        spinner.success
      end

    end

  end
end