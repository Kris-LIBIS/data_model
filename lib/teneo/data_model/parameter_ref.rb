# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ParameterRef < Base
    self.table_name = 'parameter_refs'

    DELEGATION_TERMINATOR = /[\s,;]+/
    DELEGATION_JOINER = '#'

    belongs_to :with_param_refs, polymorphic: true

    validates :name, presence: true
    validates :delegation, presence: true
    validates :with_param_refs_id, presence: true
    validates :with_param_refs_type, presence: true

    def self.from_hash(hash, id_tags = [:with_param_refs_type, :with_param_refs_id, :name])
      super(hash, id_tags)
    end

    def referenced_parameters(delegation = nil)
      with_param_refs.child_parameters(delegation || self.delegation)
    end

    def referenced_parameter(delegation = nil)
      referenced_parameters(delegation).first
    end

    def reference_tree
      delegation.split(DELEGATION_TERMINATOR)
      referenced_parameters.each_with_object(Hash.new { |h, k| h[k] = {} }) do |param, result|
        case param
        when ParameterRef
          result
        else # ParameterDef

        end
        result[param_ref.name] = child_parameter(param_ref.delegation).to_hash.merge(param_ref.to_hash)
      end
    end

  end

end
