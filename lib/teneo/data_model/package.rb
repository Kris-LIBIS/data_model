# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Package < Base
    self.table_name = 'packages'

    belongs_to :ingest_workflow

    has_many :items, as: :parent

  end

end
