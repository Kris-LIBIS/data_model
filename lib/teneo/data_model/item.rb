# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Item < Base
    self.table_name = 'items'

    belongs_to :parent, polymorphic: true

    has_many :items, as: :parent

  end

end
