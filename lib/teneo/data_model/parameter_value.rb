# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ParameterValue < Base
    self.table_name = 'parameter_values'

    belongs_to :with_value, polymorphic: true

    validates :name, presence: true
    validates :with_value_id, presence: true
    validates :with_value_type, presence: true

  end

end
