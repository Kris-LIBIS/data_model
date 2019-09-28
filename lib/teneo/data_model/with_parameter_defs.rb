# frozen_string_literal: true
require 'active_support/concern'
require_relative 'with_parameter'

module Teneo
  module DataModel
    module WithParameterDefs
      include WithParameter

      extend ActiveSupport::Concern

      included do
        # noinspection RailsParamDefResolve
        self.has_many :parameter_defs, as: :with_param_defs, class_name: 'Teneo::DataModel::ParameterDef'
      end

      def parameters
        parameter_defs
      end

      def params_from_hash(params)
        return unless params
        parameter_defs.clear
        params.each do |name, definition|
          definition[:name] = name
          definition[:with_param_defs_type] = self.class.name
          definition[:with_param_defs_id] = self.id
          parameter_defs << Teneo::DataModel::ParameterDef.from_hash(definition)
        end
        save!
        self
      end

    end

  end
end