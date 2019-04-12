# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestJob < Base
    self.table_name = 'ingest_jobs'

    with_options inverse_of: :ingest_jobs do |model|
      model.belongs_to :ingest_agreement
      model.belongs_to :workflow
    end

  end

end
