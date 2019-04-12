# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class StatusLog < Base
    self.table_name = 'status_logs'

    belongs_to :item

    has_many :items, as: :parent

  end

end
