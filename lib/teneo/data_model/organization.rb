# frozen_string_literal: true
require 'active_support/core_ext/object/with_options'

require_relative 'base'
require_relative 'serializers/hash_serializer'

module Teneo
  module DataModel
    # noinspection RailsParamDefResolve
    class Organization < Base
      self.table_name = 'organizations'

      with_options dependent: :destroy, inverse_of: :organization do |model|
        model.has_many :memberships
        model.has_many :ingest_agreements
      end

      # serialize :upload_areas, Teneo::DataModel::Serializers::HashSerializer

    end
  end
end