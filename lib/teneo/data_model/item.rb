# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Item < Base
    self.table_name = 'items'

    belongs_to :package
    has_many :status_logs

    belongs_to :parent, polymorphic: true

  end

end
