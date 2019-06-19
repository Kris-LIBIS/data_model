# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestTask < Base
    self.table_name = 'ingest_tasks'

    STAGE_LIST = Teneo::DataModel::Workflow::STAGE_LIST

    with_options inverse_of: :ingest_tasks do |model|
      model.belongs_to :ingest_job
      model.belongs_to :workflow
    end

    has_many :values, as: :with_values, class_name: 'Teneo::DataModel::ParameterValue'

    validates :stage, presence: true, inclusion: {in: STAGE_LIST}
    validates_each :workflow do |record, attr, value|
      record.errors.add attr, 'stage does not match' unless value.nil? || value.stage == record.stage
    end


    def self.from_hash(hash, id_tags = [:ingest_job_id, :stage])
      ingest_job = hash.delete(:ingest_job)
      query = ingest_job ? {name: ingest_job} : {id: hash[:ingest_job_id]}
      ingest_job = Teneo::DataModel::IngestJob.find_by!(query)
      hash[:ingest_job_id] = ingest_job.id

      params = hash.delete(:values)

      item = super(hash, id_tags) do |item, h|
        if (workflow = h.delete(:workflow))
          item.workflow = Teneo::DataModel::Workflow.find_by!(name: workflow)
        end
      end

      if params
        item.values.clear
        params.each do |name, value|
          item.values << Teneo::DataModel::ParameterValue.from_hash(name: name, value: value,
                                                                    with_values_id: item.id,
                                                                    with_values_type: item.class.name)
        end
        item.save!
      end

      item
    end

  end

end
