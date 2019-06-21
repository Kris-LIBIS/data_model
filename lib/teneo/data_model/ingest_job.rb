# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestJob < Base
    self.table_name = 'ingest_jobs'

    belongs_to :ingest_agreement, inverse_of: :ingest_jobs

    has_many :ingest_tasks
    has_many :workflows, through: :ingest_tasks

    has_many :parameter_refs, as: :with_param_refs, class_name: 'Teneo::DataModel::ParameterRef'

    validates :name, presence: true

    def parameter_def(param_name)
      ref = parameter_refs.find_by(name: param_name)
      return nil unless ref
      delegation = ref.delegation
      target, name = delegation.split(/[,\s]+/).first.split('#')
      task = ingest_tasks.find_by(stage: target)
      workflow = task.workflow
      result = workflow.parameter_def(name)
      if (param_value = task.parameter_values.find_by(name: name))
        result[:default] = param_value.value
      end
      result.merge(ref.to_hash.select {|k,_| [:description, :help, :default].include?(k)})
    end

    def self.from_hash(hash, id_tags = [:ingest_agreement_id, :name])
      agreement_name = hash.delete(:ingest_agreement)
      query = agreement_name ? {name: agreement_name} : {id: hash[:ingest_agreement_id]}
      ingest_agreement = record_finder Teneo::DataModel::IngestAgreement, query
      hash[:ingest_agreement_id] = ingest_agreement.id

      params = hash.delete(:parameters)
      tasks = hash.delete(:tasks)

      item = super(hash, id_tags) do |item, h|
        if (workflow = h.delete(:workflow))
          item.workflow = record_finder Teneo::DataModel::Workflow, name: workflow
        end
      end

      if params
        item.parameter_refs.clear
        params.each do |name, definition|
          item.parameter_refs <<
              Teneo::DataModel::ParameterRef.from_hash(definition.merge(name: name,
                                                                        with_param_refs_id: item.id,
                                                                        with_param_refs_type: item.class.name))
        end
        item.save!
      end

      if tasks
        item.ingest_tasks.clear
        tasks.each do |task|
          task[:ingest_job_id] = item.id
          item.ingest_tasks << Teneo::DataModel::IngestTask.from_hash(task)
        end
        item.save!
      end

      item
    end

  end

end
