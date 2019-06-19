# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ConversionJob < Base
    self.table_name = 'conversion_jobs'

    belongs_to :representation

    has_many :conversion_tasks, inverse_of: :conversion_job

    array_field :input_formats

    validates :representation_id, presence: true
    validates :name, presence: true, uniqueness: {scope: :representation_id}
    validates :position, presence: true, uniqueness: {scope: :representation_id}

    def self.from_hash(hash, id_tags = [:representation_id, :name])
      representation_label = hash.delete(:representation)
      query = representation_label ? {label: representation_label} : {id: hash[:representation_id]}
      representation = Teneo::DataModel::Representation.find_by!(query)
      hash[:representation_id] = representation.id

      conversion_tasks = hash.delete(:tasks)

      item = super(hash, id_tags) do |item, h|
        item.position = (position = h.delete(:position)) ? position : item.position = item.representation.conversion_jobs.count
      end

      if conversion_tasks
        item.conversion_tasks.clear
        conversion_tasks.each_with_index do |conversion_task, index|
          item.conversion_tasks <<
              Teneo::DataModel::ConversionTask.from_hash(conversion_task.merge(conversion_job_id: item.id,
                                                                               position: index + 1))
        end
        item.save!
      end
      item
    end

  end

end
