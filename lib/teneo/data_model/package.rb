# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Package < Base

    include Libis::Workflow::Job

    self.table_name = 'packages'

    belongs_to :ingest_workflow

    has_many :items, inverse_of: :package
    has_many :runs, inverse_of: :package

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

      params = params_from_values(hash.delete(:values))

      super(hash, id_tags).params_from_hash(params)
    end

    def tasks
      ingest_workflow.tasks_info
    end

    def make_run
      run = Run.new(name: run_name, package: self)
      runs << run
      run.save
      run
    end

    def last_run
      runs.order_by(created_at: :desc).first
    end

    def <<(item)
      item.package = self
    end

    def item_list
      items.to_a
    end

  end

end
