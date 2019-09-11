# frozen_string_literal: true
require 'active_record'
require 'active_support/core_ext/hash/compact'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/with_options'
require 'acts_as_list'

require 'active_support/concern'

module Teneo
  module DataModel
    module WithParameterRefs

      extend ActiveSupport::Concern

      included do
        # noinspection RailsParamDefResolve
        self.has_many :parameter_refs, as: :with_param_refs, class_name: 'Teneo::DataModel::ParameterRef'
      end

      def parameters
        parameter_refs.each_with_object(Hash.new { |h, k| h[k] = {} }) do |param_ref, result|
          result[param_ref.name] = child_parameter(param_ref.delegation).to_hash.merge(param_ref.to_hash)
        end
      end

      def parameter_values
        parameter_refs.each_with_object(Hash.new { |h, k| h[k] = {} }) do |param_ref, result|
          next if param_ref.value
          result[param_ref.name] = param_ref.default || child_parameter(param_ref.delegation).value
        end
      end

      def params_from_hash(params)
        return unless params
        parameter_refs.clear
        params.each do |name, definition|
          definition[:name] = name
          definition[:with_param_refs_type] = self.class.name
          definition[:with_param_refs_id] = self.id
          parameter_refs << Teneo::DataModel::ParameterRef.from_hash(definition)
        end
        save!
        self
      end

      def parameter_children
        [] # To override in klass
      end

      class_methods do
        def params_from_values(delegate, values = {})
          return {} unless values
          values.each_with_object(Hash.new { |h, k| h[k] = {} }) do |(name, value), result|
            delegation = "#{delegate}#{ParameterRef::DELEGATION_JOINER}#{name}"
            result[delegation] = {delegation: delegation, value: value}
          end
        end
      end

      def child_parameters(delegation = nil)
        @ref_params = parameter_children.each_with_object(Hash.new { |h, k| h[k] = {} }) do |child, result|
          child.parameters.each do |name, param|
            result[name] = param
          end
        end
        return @ref_params unless delegation
        delegation.split(ParameterRef::DELEGATION_TERMINATOR).each_with_object([]) do |d, result|
          if (x = @ref_params[d])
            result << x
          else
            @ref_params.each { |param| result << param if /%^#{d}/ =~ param[:delegation] }
          end
        end
      end

      def child_parameter(delegation = nil)
        child_parameters(delegation).first
      end

    end

  end
end