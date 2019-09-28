# frozen_string_literal: true
require 'active_record'
require 'active_support/core_ext/hash/reverse_merge'

require 'active_support/concern'

require_relative 'parameter_ref'
require_relative 'with_parameter'

module Teneo
  module DataModel
    module WithParameterRefs
      include WithParameter

      extend ActiveSupport::Concern

      included do
        # noinspection RailsParamDefResolve
        self.has_many :parameter_refs, as: :with_param_refs, class_name: 'Teneo::DataModel::ParameterRef'
      end

      def parameters
        parameter_refs
      end

      def parameters_hash_for(delegation, recursive: true, algo: :collapse)
        regex = begin
                  ParameterRef.delegation_search(delegation)
                rescue RuntimeError
                  return {}
                end
        parameters_hash(recursive: recursive, algo: algo).each_with_object({}) do |(_k, v), result|
          if v[:delegation]&.any? { |x| x =~ regex }
            result[$1] = v
          end
        end
      end

      def child_parameters
        parameter_children.map(&:parameters).map(&:all).flatten
      end

      def parameters_hash(recursive: false, algo: nil)
        result = super
        parameter_children.each do |child|
          child.parameters_hash(recursive: true, algo: algo).each do |name, param|
            case algo
            when :tree
              matches = result.select { |_k, v| v[:delegation]&.include?(name) }
              matches.each { |_k, v| (v[:delegates] ||= {})[name] = param }
              result[name] = param if matches.empty?
            when :collapse
              matches = result.select { |_k, v| v[:delegation]&.include?(name) }
              matches.each do |_k, v|
                v[:hosts] += param[:hosts]
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

      def child_parameters_hash(delegation = nil, recursive: true, algo: :collapse)
        regex = delegation ?
                    ParameterRef.delegation_search(delegation) :
                    Regexp.new("^((#{parameter_children.map { |c| Regexp.escape(c.name) }.join('|')})#\\K(.*))$")
        parameter_children.each_with_object({}) do |child, result|
          child.parameters_hash(recursive: recursive, algo: algo).each do |name, param|
            next unless name =~ regex
            result[$1] = param
          end
        end
      end

      def child_parameter_hash(delegation = nil)
        child_parameters_hash(delegation).first
      end

      def params_from_hash(params)
        return unless params
        parameter_refs.clear
        params.each do |name, definition|
          definition[:name] ||= name
          definition[:with_param_refs_type] = self.class.name
          definition[:with_param_refs_id] = self.id
          definition[:export] = true unless definition.has_key?(:export)
          delegates = definition.delete(:delegation).map do |delegation|
            host, param = ParameterRef::delegation_split(delegation)
            delegation_host = parameter_children.find { |child| child.name == host }
            delegation_host.parameters.find_by!(name: param)
          rescue ActiveRecord::RecordNotFound
            raise RuntimeError,
                  "Parameter #{param} not found in #{delegation_host.class} '#{delegation_host.name}' for #{name}"
          end
          param_ref = Teneo::DataModel::ParameterRef.from_hash(definition)
          delegates.each { |delegate| param_ref << delegate }
          parameter_refs << param_ref
        end
        save!
        self
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