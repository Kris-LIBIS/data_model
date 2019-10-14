# frozen_string_literal: true
require_relative 'base'
require_relative 'serializers/hash_serializer'
require 'active_support/core_ext/hash/indifferent_access'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Item < Base

    include Libis::Workflow::WorkItem

    self.table_name = 'items'

    belongs_to :package
    has_many :status_logs

    belongs_to :parent, inverse_of: :items, class_name: self.name
    has_many :items, inverse_of: :parent, foreign_key: :parent_id

    serialize :options, Serializers::HashSerializer
    serialize :properties, Serializers::HashSerializer

    def job
      package
    end

    def <<(item)
      item.parent = self
    end

    def item_list
      items.to_a
    end

  end

end
