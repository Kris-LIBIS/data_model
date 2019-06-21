# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class Workflow < Base
    self.table_name = 'workflows'

    STAGE_LIST = Teneo::DataModel::Task::STAGE_LIST

    has_many :workflow_tasks, -> { order(position: :asc) }, inverse_of: :workflow
    has_many :tasks, through: :workflow_tasks

    has_many :ingest_tasks, inverse_of: :workfow

    has_many :parameter_refs, as: :with_param_refs, class_name: 'Teneo::DataModel::ParameterRef'

    validates :name, presence: true
    validates :stage, presence: true, inclusion: {in: STAGE_LIST}

    def parameter_def(param_name)
      ref = parameter_refs.find_by(name: param_name)
      return nil unless ref
      delegation = ref.delegation
      target, name = delegation.split(/[,\s]+/).first.split('#')
      task = tasks.find_by(name: target)
      workflow_task = workflow_tasks.find_by(task_id: task.id)
      result = task.parameter_defs.find_by(name: name)&.to_hash
      result.delete(:with_parameters_type)
      result.delete(:with_parameters_id)
      if (param_value = workflow_task.parameter_values.find_by(name: name))
        result[:default] = param_value.value
      end
      result.merge(ref.to_hash.select {|k,_| [:description, :help, :default].include?(k)})
    end

    def self.from_hash(hash, id_tags = [:name])
      params = hash.delete(:parameters)
      tasks = hash.delete(:tasks)
      item = super(hash, id_tags)
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
        item.workflow_tasks.clear
        tasks.each_with_index do |task, index|
          task[:workflow_id] = item.id
          task[:position] = index + 1
          item.workflow_tasks << Teneo::DataModel::WorkflowTask.from_hash(task)
        end
        item.save!
      end
      item
    end

  end

end
