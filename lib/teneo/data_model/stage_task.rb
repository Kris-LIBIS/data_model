# frozen_string_literal: true
require 'active_support/core_ext/object/with_options'

require_relative 'base'

module Teneo
  module DataModel
    # noinspection RailsParamDefResolve
    class StageTask < Base
      self.table_name = 'stage_tasks'

      belongs_to :stage_workflow
      acts_as_list scope: :stage_workflow, add_new_at: :bottom

      belongs_to :task

      has_many :parameter_values, as: :with_values, class_name: 'Teneo::DataModel::ParameterValue'

      validates :position, uniqueness: {scope: :stage_workflow_id}

      before_validation :init_position

      def init_position
        # noinspection RubyResolve
        self.position ||= self.class.where(stage_workflow_id: stage_workflow_id).pluck(:position).max + 1
      end

      def self.from_hash(hash, id_tags = [:stage_workflow_id, :position])
        params = hash.delete(:values)
        item = super(hash, id_tags) do |item, h|
          item.position = (position = h.delete(:position)) ? position : item.stage_workflow.stage_tasks.count
          if (task = h.delete(:task))
            item.task = record_finder Teneo::DataModel::Task, name: task
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
end
