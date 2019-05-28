# frozen_string_literal: true
require_relative 'base'
require_relative 'serializers/hash_serializer'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ParameterDef < Base
    self.table_name = 'parameter_defs'

    DATA_TYPE_LIST = %w'string integer float bool hash array array_string array_integer array_float array_bool'

    belongs_to :with_parameters, polymorphic: true

    validates :name, presence: true
    validates :data_type, presence: true
    validates :with_parameters_id, presence: true
    validates :with_parameters_type, presence: true

  end

end
