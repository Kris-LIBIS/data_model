# frozen_string_literal: true
require_relative 'base_sorted'
require_relative 'serializers/hash_serializer'
require 'active_support/core_ext/hash/indifferent_access'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Item < BaseSorted
    self.table_name = 'items'
    ranks :position, class_name: self.name, with_same: [:parent_id, :parent_type]

    has_many :status_logs, inverse_of: :item, dependent: :nullify
    has_many :message_logs, inverse_of: :item, dependent: :nullify
    has_one :metadata_record, inverse_of: :item, dependent: :destroy

    belongs_to :parent, polymorphic: true
    has_many :items, -> { rank(:position) }, as: :parent, class_name: 'Teneo::DataModel::Item', dependent: :destroy

    serialize :options, Serializers::HashSerializer
    serialize :properties, Serializers::HashSerializer

  end

end
