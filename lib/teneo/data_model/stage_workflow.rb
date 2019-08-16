# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class StageWorkflow < Base
    self.table_name = 'stage_workflows'

    STAGE_LIST = Teneo::DataModel::Task::STAGE_LIST

    has_many :stage_tasks, -> { order(position: :asc) }, inverse_of: :stage_workflow
    has_many :tasks, through: :stage_tasks

    has_many :ingest_tasks, inverse_of: :stage_workfow

    has_many :parameter_refs, as: :with_param_refs, class_name: 'Teneo::DataModel::ParameterRef'

    validates :name, presence: true
    validates :stage, presence: true, inclusion: {in: STAGE_LIST}

    def parameter_def(param_name)
      ref = parameter_refs.find_by(name: param_name)
      return nil unless ref
      delegation = ref.delegation
      target, name = delegation.split(/[,\s]+/).first.split('#')
      task = tasks.find_by(name: target)
      stage_task = stage_tasks.find_by(task_id: task.id)
      result = task.parameter_defs.find_by(name: name)&.to_hash
      result.delete(:with_parameters_type)
      result.delete(:with_parameters_id)
      if (param_value = stage_task.parameter_values.find_by(name: name))
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
        item.stage_tasks.clear
        tasks.each do |task|
          task[:stage_workflow_id] = item.id
          item.stage_tasks << Teneo::DataModel::StageTask.from_hash(task)
        end
        item.save!
      end
      item
    end

  end

end
