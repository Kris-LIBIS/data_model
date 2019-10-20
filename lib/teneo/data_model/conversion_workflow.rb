# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ConversionWorkflow < Base
    self.table_name = 'conversion_workflows'

    belongs_to :representation
    acts_as_list scope: :representation, add_new_at: :bottom

    has_many :conversion_tasks, -> { order(position: :asc) }, inverse_of: :conversion_workflow, dependent: :destroy
    has_many :conversions, through: :conversion_tasks

    array_field :input_formats

    validates :representation_id, presence: true
    validates :name, presence: true, uniqueness: {scope: :representation_id}

    def self.from_hash(hash, id_tags = [:representation_id, :name])
      representation_label = hash.delete(:representation)
      query = representation_label ? {label: representation_label} : {id: hash[:representation_id]}
      representation = record_finder Teneo::DataModel::Representation, query
      hash[:representation_id] = representation.id

      tasks = hash.delete(:tasks) || []

      super(hash, id_tags).tap do |item|
        item.conversion_tasks.clear
        if tasks
          tasks.each do |task|
            task[:conversion_workflow_id] = item.id
            item.conversion_tasks << Teneo::DataModel::ConversionTask.from_hash(task)
          end
        end
      end
    end

  end

end
