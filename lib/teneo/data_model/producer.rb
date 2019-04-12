# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Producer < Base
    self.table_name = 'producers'

    has_many :ingest_agreements,
             dependent: :destroy,
             inverse_of: :material_flow
  end

end
