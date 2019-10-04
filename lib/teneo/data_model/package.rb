# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Package < Base
    self.table_name = 'packages'

    belongs_to :ingest_workflow
    belongs_to :ingest_model

    has_many :items, as: :parent
    has_many :parameter_values, as: :with_values, class_name: 'Teneo::DataModel::ParameterValue'

    validate :safe_name

    WithParameters

    def parameter_children
      [ingest_workflow]
    end

    def self.from_hash(hash, id_tags = [:ingest_workflow_id, :name])
      ingest_workflow_name = hash.delete(:ingest_workflow)
      query = ingest_workflow_name ? {name: ingest_workflow_name} : {id: hash[:ingest_workflow_id]}
      ingest_workflow = record_finder Teneo::DataModel::IngestWorkflow, query
      hash[:ingest_workflow_id] = ingest_workflow.id

      ingest_model_query = {id: hash.delete(:ingest_model_id), name: hash.delete(:ingest_model)}.compact
      ingest_model = begin
        model = record_finder Teneo::DataModel::IngestModel, ingest_model_query
        model.ingest_agreement == ingest_workflow.ingest_agreement ? model : nil
      rescue ActiveRecord::RecordNotFound
        nil
      end unless ingest_model_query.empty?
      ingest_model ||= ingest_workflow.ingest_agreement.ingest_models.first
      hash[:ingest_model_id] = ingest_model.id

      params = params_from_values(hash.delete(:values))

      super(hash, id_tags).params_from_hash(params)
    end

  end

end
