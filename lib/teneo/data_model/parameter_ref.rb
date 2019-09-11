# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ParameterRef < Base
    self.table_name = 'parameter_refs'

    belongs_to :with_param_refs, polymorphic: true

    validates :name, presence: true
    validates :delegation, presence: true
    validates :with_param_refs_id, presence: true
    validates :with_param_refs_type, presence: true

    def self.from_hash(hash, id_tags = [:with_param_refs_type, :with_param_refs_id, :name])
      super(hash, id_tags)
    end

  end

end
