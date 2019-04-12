# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class MaterialFlow < Base
    self.table_name = 'material_flows'

    has_many :ingest_agreements,
             dependent: :destroy,
             inverse_of: :material_flow
  end

end
