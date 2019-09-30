# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel
  # noinspection RailsParamDefResolve
  class Storage < Base
    self.table_name = 'storages'

    belongs_to :organization, inverse_of: :storages
    belongs_to :storage_type, inverse_of: :storages

    include WithParameters

    def parameter_children
      [storage_type]
    end

    def self.from_hash(hash, id_tags = [:name, :organization_id])
      params = {}

      super(hash, id_tags) do |item, h|
        protocol = h.delete(:protocol)
        item.storage_type = record_finder(Teneo::DataModel::StorageType, protocol: protocol)
        params.merge!(params_from_values(protocol, h.delete(:values)))
      end.params_from_hash(params)
    end

  end
end
