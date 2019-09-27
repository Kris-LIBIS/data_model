# frozen_string_literal: true
require 'active_record'
require 'active_support/core_ext/hash/reverse_merge'

require 'active_support/concern'

require_relative 'parameter_ref'

module Teneo
  module DataModel
    module WithParameterRefs

      extend ActiveSupport::Concern

      included do
        # noinspection RailsParamDefResolve
        self.has_many :parameter_refs, as: :with_param_refs, class_name: 'Teneo::DataModel::ParameterRef'
      end

      def parameter_name(name)
        name =~ /#/ ? name : "#{self.name}##{name}"
      end

      def parameter_values(include_export = false)
        parameter_refs.each_with_object(Hash.new { |h, k| h[k] = {} }) do |param_ref, result|
          next unless include_export || !param_ref.export
          param_ref.delegation.each do |delegation|
            result[delegation] = param_ref.default || child_parameter(delegation)[:default]
          end
        end
      end

      def parameter_objects
        parameter_refs
      end

      def parameters(recursive: false, algo: nil)
        result = parameter_refs.each_with_object(Hash.new { |h, k| h[k] = {} }) do |param_ref, result|
          result[parameter_name(param_ref.name)] = param_ref.to_hash
        end
        parameter_children.each do |param_child|
          param_child.parameters(recursive: true, algo: algo).each do |name, param|
            case algo
            when :tree
              matches = result.select { |_k, v| v[:delegation]&.include?(name) }
              matches.each { |_k, v| (v[:delegates] ||= {})[name] = param }
              result[name] = param if matches.empty?
            when :collapse
              matches = result.select { |_k, v| v[:delegation]&.include?(name) }
              matches.each do |_k, v|
                v[:delegation] += param[:delegation] || []
                v[:with_param_refs] ||= []
                v[:with_param_refs] += param[:with_param_refs] || []
                v[:with_parameters] ||= []
                v[:with_parameters] += param[:with_parameters] || []
                v.reverse_merge! param
              end
              result[name] = param if matches.empty?
            else
              result[name].reverse_merge! param
            end
          end
        end if recursive
        result
      end

      def parameters_for(delegation, recursive: true, algo: :collapse)
        regex = ParameterRef.delegation_search(delegation)
        parameters(recursive: recursive, algo: algo).each_with_object({}) do |(_k, v), result|
          if v[:delegation]&.any? { |x| x =~ regex }
            result[$1] = v
          end
        end
      rescue RuntimeError
        {}
      end

      def child_parameters(delegation = nil, recursive: true, algo: :collapse)
        regex = delegation ?
                    ParameterRef.delegation_search(delegation) :
                    Regexp.new("^((#{parameter_children.map { |c| Regexp.escape(c.name) }.join('|')})#\\K(.*))$")
        puts regex
        parameter_children.each_with_object({}) do |child, result|
          child.parameters(recursive: recursive, algo: algo).each do |name, param|
            next unless name =~ regex
            result[$1] = param
          end
        end
      end

      def child_parameter(delegation = nil)
        child_parameters(delegation).first
      end

      def params_from_hash(params)
        return unless params
        parameter_refs.clear
        params.each do |name, definition|
          definition[:name] ||= name
          definition[:with_param_refs_type] = self.class.name
          definition[:with_param_refs_id] = self.id
          definition[:export] = true unless definition.has_key?(:export)
          delegates = []
          definition[:delegation].each do |delegation|
            host, param = ParameterRef::delegation_split(delegation)
            delegation_host = parameter_children.find { |child| child.name == host }
            begin
              delegate = delegation_host.parameter_objects.find_by!(name: param)
            rescue ActiveRecord::RecordNotFound
              raise RuntimeError, "parameter #{param} not found in #{delegation_host.name} for #{self.name}"
            end
            delegates << delegate
          end
          param_ref = Teneo::DataModel::ParameterRef.from_hash(definition)
          delegates.each do |delegate|
            delegation = ParameterDelegation.new(delegate: delegate, parameter_ref: param_ref)
            delegate.parameter_delegations << delegation
            delegate.save!
          end
          parameter_refs << param_ref
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
            delegation = "#{delegate}##{name}"
            result[delegation] = {name: name, delegation: [delegation], default: value, export: false}
          end
        end
      end

    end

  end
end