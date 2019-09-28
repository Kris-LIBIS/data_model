# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ParameterDef < Base
    self.table_name = 'parameter_defs'

    DATA_TYPE_LIST = %w'string integer float bool hash array array_string array_integer array_float array_bool'

    belongs_to :with_param_defs, polymorphic: true

    has_many :parameter_delegations, as: :delegate
    has_many :parameter_refs, through: :parameter_delegations

    validates :name, presence: true
    validates :with_param_defs_id, presence: true
    validates :with_param_defs_type, presence: true

    def self.from_hash(hash, id_tags = [:with_param_defs_type, :with_param_defs_id, :name])
      super(hash, id_tags)
    end

    def delegation_name
      "#{with_param_defs.name}##{name}"
    end

    def to_hash
      # noinspection RubyResolve
      super.tap {|h| h[:host] = [[with_param_defs_type, with_param_defs_id]] }
    end

    def value
      default
    end

    protected

    def volatile_attributes
      super + %w'with_parameters_id with_parameters_type'
    end

  end

end
