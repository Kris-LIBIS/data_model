# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ParameterValue < Base
    self.table_name = 'parameter_values'

    belongs_to :with_values, polymorphic: true

    validates :name, presence: true
    validates :with_values_id, presence: true
    validates :with_values_type, presence: true

    def self.from_hash(hash, id_tags = [:with_values_type, :with_values_id, :name])
      super(hash, id_tags)
    end

  end

end
