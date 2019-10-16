# frozen_string_literal: true
require_relative 'base'
require_relative 'serializers/hash_serializer'
require 'active_support/core_ext/hash/indifferent_access'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Item < Base

    self.table_name = 'items'

    belongs_to :package
    has_many :status_logs

    belongs_to :parent, inverse_of: :items, class_name: self.name
    has_many :items, inverse_of: :parent, foreign_key: :parent_id

    # noinspection RubyExpressionInStringInspection
    # acts_as_list scope: 'parent_id = #{parent_id} AND package_id = #{package_id}', add_new_at: :bottom

    serialize :options, Serializers::HashSerializer
    serialize :properties, Serializers::HashSerializer

  end

end
