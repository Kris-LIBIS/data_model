# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class Task < Base
    self.table_name = 'tasks'

    STAGE_LIST = Teneo::DataModel::IngestJob::STAGE_LIST

    has_many :workflow_tasks, inverse_of: :task
    has_many :workflows, through: :workflow_tasks

    has_many :parameter_defs, as: :with_parameters

    validates :stage, presence: true, inclusion: {in: STAGE_LIST}
    validates :name, presence: true
    validates :class_name, presence: true

    def self.from_hash(hash, id_tags = [:name])
      parameters = hash.delete('parameters')
      item = super(hash, id_tags)
      parameters.each do |name, definition|
        item.parameter_defs << Teneo::DataModel::ParameterDef.from_hash(definition.
            merge('name' => name, 'with_parameters_id => item.id' => item.id, 'with_parameters_type' => item.class.name))
      end
      item
    end

  end

end
