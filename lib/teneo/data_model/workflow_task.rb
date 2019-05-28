# frozen_string_literal: true
require 'active_support/core_ext/object/with_options'

require_relative 'base'

module Teneo
  module DataModel
    # noinspection RailsParamDefResolve
    class WorkflowTask < Base
      self.table_name = 'workflow_tasks'

      belongs_to :workflow
      belongs_to :task

      has_many :values, as: :with_values

      validates :position, uniqueness: {scope: :workflow_id}

      def self.from_hash(hash, id_tags = [:manifestation_id, :name])
        values = hash.delete('values')
        item = super(hash, id_tags) do |item, h|
          item.position = (position = h.delete(:position)) ? position : item.workflow.workflow_tasks.count
        end
        values.each do |name, value|
          item.values << Teneo::DataModel::ParameterValue.from_hash('name' => name, 'value' => value,
                                                                    'with_values_id' => item.id,
                                                                    'with_values_type' => item.class.name)
        end
        item
      end

    end
  end
end
