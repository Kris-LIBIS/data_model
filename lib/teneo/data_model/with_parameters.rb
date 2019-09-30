# frozen_string_literal: true
require 'active_support/concern'

module Teneo
  module DataModel
    module WithParameters

      extend ActiveSupport::Concern

      included do
        # noinspection RailsParamDefResolve
        self.has_many :parameters, as: :with_parameters, class_name: 'Teneo::DataModel::Parameter'
      end

      def parameter_children
        []
      end

      def parameters_hash(recursive: false, algo: nil)
        result = parameters.each_with_object({}) do |param, result|
          result[param.reference_name] = param.to_hash
        end
        parameter_children.each do |child|
          child.parameters_hash(recursive: true, algo: algo).each do |reference, param|
            matches = result.select { |_k, v| v[:references]&.include?(reference) }
            case algo
            when :tree
              matches.each { |_k, v| (v[:targets] ||= {})[reference] = param }
              result[reference] = param if matches.empty?
            when :collapse
              matches.each do |_k, v|
                v[:references] += param[:references]
                v.reverse_merge! param
              end
              result[reference] = param if matches.empty?
            else
              result[reference] ||= {}
              result[reference].reverse_merge! param
            end
          end
        end if recursive
        result
      end

      def parameters_hash_for(reference, recursive: true, algo: :collapse)
        regex = Parameter.reference_search(reference)
        parameters_hash(recursive: recursive, algo: algo).each_with_object({}) do |(_k, v), result|
          if v[:references]&.any? { |x| x =~ regex }
            result[$1] = v
          end
        end
      rescue RuntimeError
        {}
      end

      def child_parameters(export_only: false, unmapped_only: false)
        parameter_children.map(&:parameters).map(&:all).flatten.reject do |p|
          (export_only && !p.export) || (unmapped_only && p.sources.exists?(with_parameters: self))
        end
      end

      def child_parameters_hash(reference = nil, recursive: true, algo: :collapse)
        regex = reference ?
                    Parameter.reference_search(reference) :
                    Regexp.new("^((#{parameter_children.map { |c| Regexp.escape(c.name) }.join('|')})#\\K(.*))$")
        parameter_children.each_with_object({}) do |child, result|
          child.parameters_hash(recursive: recursive, algo: algo).each do |name, param|
            next unless name =~ regex
            result[$1] = param
          end
        end
      end

      def child_parameter_hash(reference = nil)
        child_parameters_hash(reference).first
      end

      def parameter_values(include_export = false)
        parameters.each_with_object({}) do |param, result|
          next unless include_export || (param.respond_to?(:export) && !param.export)
          result[param.name] = param.default
        end
      end

      def params_from_hash(params)
        return unless params
        parameters.clear
        params.each do |name, definition|
          definition[:name] = name
          definition[:with_parameters_type] = self.class.name
          definition[:with_parameters_id] = self.id
          definition[:export] = true unless definition.has_key?(:export)
          targets = definition.delete(:targets) || []
          parameter = Teneo::DataModel::Parameter.from_hash(definition)
          parameters << parameter
          parameter.target_list = targets
        end
        save!
        self
      end

      class_methods do

        def params_from_values(target_host, values = {})
          return {} unless values
          values.each_with_object(Hash.new { |h, k| h[k] = {} }) do |(name, value), result|
            reference = "#{target_host}##{name}"
            ref_name = "#{target_host}##{name}"
            result[ref_name] = {name: ref_name, targets: [reference], default: value, export: false}
          end
        end

      end

    end

  end
end