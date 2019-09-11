# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel
  # noinspection RailsParamDefResolve
  class Storage < Base
    self.table_name = 'storages'

    belongs_to :organization, inverse_of: :storages
    belongs_to :storage_type, inverse_of: :storages

    include WithParameterRefs

    def parameter_children
      [storage_type]
    end

    def self.from_hash(hash, id_tags = [:name, :organization_id])
      params = params_from_values(hash.delete(:values))

      super(hash, id_tags) do |item, h|
        item.storage_type = record_finder(Teneo::DataModel::StorageType, protocol: hash.delete(:protocol))
      end.params_from_hash(params)
    end

  end
end
