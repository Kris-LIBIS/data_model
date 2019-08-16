# frozen_string_literal: true
require_relative 'base'
require 'order_as_specified'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestTask < Base
    extend OrderAsSpecified
    self.table_name = 'ingest_tasks'

    STAGE_LIST = Teneo::DataModel::StageWorkflow::STAGE_LIST

    with_options inverse_of: :ingest_tasks do |model|
      model.belongs_to :ingest_workflow
      model.belongs_to :stage_workflow
    end

    has_many :parameter_values, as: :with_values, class_name: 'Teneo::DataModel::ParameterValue'

    validates :stage, presence: true, inclusion: {in: STAGE_LIST}, uniqueness: {scope: :ingest_workflow_id}
    validates_each :stage_workflow do |record, attr, value|
      record.errors.add attr, 'stage does not match' unless value.nil? || value.stage == record.stage
    end


    def self.from_hash(hash, id_tags = [:ingest_workflow_id, :stage])
      ingest_workflow = hash.delete(:ingest_workflow)
      query = ingest_workflow ? {name: ingest_workflow} : {id: hash[:ingest_workflow_id]}
      ingest_workflow = record_finder Teneo::DataModel::IngestWorkflow, query
      hash[:ingest_workflow_id] = ingest_workflow.id

      params = hash.delete(:values)

      item = super(hash, id_tags) do |item, h|
        if (stage_workflow = h.delete(:workflow))
          item.stage_workflow = record_finder Teneo::DataModel::StageWorkflow, name: stage_workflow
        end
      end

      if params
        item.parameter_values.clear
        params.each do |name, value|
          item.parameter_values <<
              Teneo::DataModel::ParameterValue.from_hash(name: name, value: value,
                                                         with_values_id: item.id,
                                                         with_values_type: item.class.name)
        end
        item.save!
      end

      item
    end

  end

end
