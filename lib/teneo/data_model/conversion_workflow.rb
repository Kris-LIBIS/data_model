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
    validates :position, presence: true, uniqueness: {scope: :representation_id}

    before_validation :init_position

    def init_position
      # noinspection RubyResolve
      self.position ||= self.class.where(representation_id: representation_id).pluck(:position).max + 1
    end


    def self.from_hash(hash, id_tags = [:representation_id, :name])
      representation_label = hash.delete(:representation)
      query = representation_label ? {label: representation_label} : {id: hash[:representation_id]}
      representation = record_finder Teneo::DataModel::Representation, query
      hash[:representation_id] = representation.id

      conversion_tasks = hash.delete(:tasks)

      item = super(hash, id_tags) do |item, h|
        item.position = (position = h.delete(:position)) ? position : item.position = item.representation.conversion_workflows.count
      end

      if conversion_tasks
        item.conversion_tasks.clear
        conversion_tasks.each_with_index do |conversion_task, index|
          item.conversion_tasks <<
              Teneo::DataModel::ConversionTask.from_hash(conversion_task.merge(conversion_workflow_id: item.id,
                                                                               position: index + 1))
        end
        item.save!
      end
      item
    end

  end

end
