# frozen_string_literal: true

require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Package < Base

    self.table_name = 'packages'

    belongs_to :ingest_workflow

    has_many :items, -> { order(position: :asc) }, inverse_of: :package
    has_many :runs, -> { order(created_at: :asc) }, inverse_of: :package

    has_many :parameter_values, as: :with_values, class_name: 'Teneo::DataModel::ParameterValue'

    validate :safe_name

    include WithParameters

    def parameter_children
      [ingest_workflow]
    end

    def self.from_hash(hash, id_tags = [:ingest_workflow_id, :name])
      ingest_workflow_name = hash.delete(:ingest_workflow)
      query = ingest_workflow_name ? {name: ingest_workflow_name} : {id: hash[:ingest_workflow_id]}
      ingest_workflow = record_finder Teneo::DataModel::IngestWorkflow, query
      hash[:ingest_workflow_id] = ingest_workflow.id

      params = params_from_values(ingest_workflow.name, hash.delete(:values))

      super(hash, id_tags).params_from_hash(params)
    end

  end

end
