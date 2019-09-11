# frozen_string_literal: true
require 'active_support/concern'

module Teneo
  module DataModel
    module WithParameterDefs

      extend ActiveSupport::Concern

      included do
        # noinspection RailsParamDefResolve
        self.has_many :parameter_defs, as: :with_parameters, class_name: 'Teneo::DataModel::ParameterDef'
      end

      def parameters
        parameter_defs.each_with_object(Hash.new { |h, k| h[k] = {} }) do |param_def, result|
          result["#{self.name}##{param_def.name}"] = param_def.to_hash
        end
      end

      def parameter_values
        parameter_defs.each_with_object(Hash.new { |h, k| h[k] = {} }) do |param_def, result|
          result[param_def.name] = param_def.default
        end
      end

      def params_from_hash(params)
        return unless params
        parameter_defs.clear
        params.each do |name, definition|
          definition[:name] = name
          definition[:with_parameters_type] = self.class.name
          definition[:with_parameters_id] = self.id
          parameter_defs << Teneo::DataModel::ParameterDef.from_hash(definition)
        end
        save!
        self
      end

    end

  end
end
