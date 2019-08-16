# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ConversionWorkflow < Base
    self.table_name = 'conversion_workflows'

    belongs_to :representation
    acts_as_list scope: :representation, add_new_at: :bottom

    has_many :conversion_tasks, -> { order(position: :asc) }, inverse_of: :conversion_workflow

    array_field :input_formats

    validates :representation_id, presence: true
    validates :name, presence: true, uniqueness: {scope: :representation_id}

    def self.from_hash(hash, id_tags = [:representation_id, :name])
      representation_label = hash.delete(:representation)
      query = representation_label ? {label: representation_label} : {id: hash[:representation_id]}
      representation = record_finder Teneo::DataModel::Representation, query
      hash[:representation_id] = representation.id

      conversion_tasks = hash.delete(:tasks)

      item = super(hash, id_tags)

      if conversion_tasks
        item.conversion_tasks.clear
        conversion_tasks.each do |conversion_task|
          item.conversion_tasks <<
              Teneo::DataModel::ConversionTask.from_hash(conversion_task.merge(conversion_workflow_id: item.id))
        end
        item.save!
      end
      item
    end

  end

end
