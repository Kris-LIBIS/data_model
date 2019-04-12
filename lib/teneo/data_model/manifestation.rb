# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Manifestation < Base
    self.table_name = 'manifestations'

    belongs_to :ingest_model

    belongs_to :representation_info
    belongs_to :access_right, optional: true

    belongs_to :from, -> { where ingest_model: self.ingest_model },
               class_name: 'Manifestation'
    has_many :dependencies,
             class_name: 'Manifestation',
             foreign_key: :from_id
  end

end
