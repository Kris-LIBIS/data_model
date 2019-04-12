# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestModel < Base
    self.table_name = 'ingest_models'

    belongs_to :ingest_agreement

    has_many :manifestations, dependent: :destroy

    # self-reference #template
    has_many :derivatives, dependent: :destroy,
             inverse_of: :template,
             foreign_key: :template_id
    belongs_to :template,
               inverse_of: :derivatives

    # code tables
    belongs_to :retention_policy
    belongs_to :access_right

  end

end
