# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class Workflow < Base
    self.table_name = 'workflows'

    STAGE_LIST = Teneo::DataModel::IngestJob::STAGE_LIST

    has_many :ingest_jobs, inverse_of: :workfow
    has_many :workflow_tasks, inverse_of: :workflow
    has_many :tasks, through: :workflow_tasks

    has_many :parameter_defs, as: :with_parameters

    validates :name, presence: true
    validates :stage, presence: true, inclusion: {in: STAGE_LIST}

    def self.from_hash(hash, id_tags = [:name])
      parameters = hash.delete('parameters')
      item = super(hash, id_tags)
      parameters.each do |name, definition|
        definition['name'] = name
        definition['with_parameter_id'] = item.id
        definition['with_parameter_tyoe'] = item.class.name
      item.parameter_defs << Teneo::DataModel::ParameterDef.from_hash(definition)
      end
    end

  end

end
