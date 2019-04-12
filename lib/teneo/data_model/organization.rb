# frozen_string_literal: true
require_relative 'base'

module Teneo
  module DataModel
    # noinspection RailsParamDefResolve
    class Organization < Base
      self.table_name = 'organizations'

      with_options dependent: :destroy, inverse_of: :organization do |model|
        model.has_many :memberships
        model.has_many :ingest_agreements
      end

      serialize :upload_areas, Teneo::DataModel::Serializers::HashSerializer

    end
  end
end