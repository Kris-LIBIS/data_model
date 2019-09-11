# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class Task < Base
    self.table_name = 'tasks'

    include WithParameterDefs

    STAGE_LIST = %w'Collect PreProcess PreIngest Ingest PostIngest'

    has_many :workflow_tasks, inverse_of: :task
    has_many :workflows, through: :workflow_tasks

    validates :stage, presence: true, inclusion: {in: STAGE_LIST}
    validates :name, presence: true
    validates :class_name, presence: true

    def self.from_hash(hash, id_tags = [:name])
      params = hash.delete(:parameters)
      super(hash, id_tags).params_from_hash(params)
    end

  end

end
