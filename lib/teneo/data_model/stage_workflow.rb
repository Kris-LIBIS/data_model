# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class StageWorkflow < Base
    self.table_name = 'stage_workflows'

    STAGE_LIST = Teneo::DataModel::Task::STAGE_LIST

    has_many :stage_tasks, -> { order(position: :asc) }, inverse_of: :stage_workflow
    has_many :tasks, through: :stage_tasks

    has_many :ingest_stages, inverse_of: :stage_workfow

    validates :name, presence: true
    validates :stage, presence: true, inclusion: {in: STAGE_LIST}

    def name
      stage
    end

    include WithParameterRefs

    def parameter_children
      tasks
    end

    def self.from_hash(hash, id_tags = [:name])
      params = hash.delete(:parameters) || {}
      tasks = hash.delete(:tasks) || []

      super(hash, id_tags).tap do |item|
        item.stage_tasks.clear
        tasks.each_with_index do |task, i|
          params.merge!(params_from_values(task[:task], task.delete(:values)))
          task[:stage_workflow_id] = item.id
          task[:position] = i + 1
          item.stage_tasks << Teneo::DataModel::StageTask.from_hash(task)
        end
      end.params_from_hash(params)
    end

  end

end
