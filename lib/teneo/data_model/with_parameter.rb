# frozen_string_literal: true
require 'active_support/concern'

module Teneo
  module DataModel
    module WithParameter

      extend ActiveSupport::Concern

      def parameters
        []
      end

      def parameter_children
        []
      end

      def parameters_hash(recursive: false, algo: nil)
        parameters.each_with_object({}) do |param, result|
          result[param.delegation_name] = param.to_hash.tap { |h| h[:hosts] = [v.delete(:host)] }
        end
      end

      def parameter_values(include_export = false)
        parameters.each_with_object({}) do |param, result|
          next unless include_export || (param.respond_to?(:export) && !param.export)
          result[param.name] = param.default
        end
      end

    end

  end
end