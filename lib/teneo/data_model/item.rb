# frozen_string_literal: true
require_relative 'base'
require_relative 'serializers/hash_serializer'
require 'active_support/core_ext/hash/indifferent_access'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Item < Base

    self.table_name = 'items'

    has_many :status_logs

    belongs_to :parent, polymorphic: true
    has_many :items, -> { order(position: :asc) }, as: :parent, class_name: 'Teneo::DataModel::Item'

    acts_as_list scope: :parent, add_new_at: :bottom

    serialize :options, Serializers::HashSerializer
    serialize :properties, Serializers::HashSerializer

  end

end
