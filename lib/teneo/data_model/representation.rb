# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Representation < Base
    self.table_name = 'representations'

    belongs_to :ingest_model
    acts_as_list scope: :ingest_model

    belongs_to :representation_info
    belongs_to :access_right, optional: true

    belongs_to :from, class_name: 'Representation', inverse_of: :dependencies, optional: true
    has_many :dependencies, class_name: 'Representation', foreign_key: :from_id, inverse_of: :from

    has_many :conversion_workflows, -> { order(position: :asc) }, inverse_of: :representation

    validates :position, :label, presence: true, uniqueness: {scope: :ingest_model_id}

    before_validation :init_position

    def init_position
      # noinspection RubyResolve
      self.position ||= self.class.where(ingest_model_id: ingest_model_id).pluck(:position).max + 1
    end


    def name
      label
    end

    def self.from_hash(hash, id_tags = [:ingest_model_id, :label])
      model_name = hash.delete(:ingest_model)
      query = model_name ? {name: model_name} : {id: hash[:ingest_model_id]}
      ingest_model = record_finder Teneo::DataModel::IngestModel, query
      hash[:ingest_model_id] = ingest_model.id

      conversion_workflows = hash.delete(:conversion_workflows)

      item = super(hash, id_tags) do |item, h|
        item.position = (position = h.delete(:position)) ? position : item.position = item.ingest_model.representations.count
        if (from = h.delete(:from))
          item.from = record_finder Teneo::DataModel::Representation, from_id: hash[:ingest_model_id], label: from
        end
        if (access_right = h.delete(:access_right))
          item.access_right = record_finder Teneo::DataModel::AccessRight, name: access_right
        end
        if (representation_info = h.delete(:representation_info))
          item.representation_info = record_finder Teneo::DataModel::RepresentationInfo, name: representation_info
        end
      end

      if conversion_workflows
        item.conversion_workflows.clear
        conversion_workflows.each_with_index do |conversion_workflow, index|
          item.conversion_workflows <<
              Teneo::DataModel::ConversionWorkflow.from_hash(conversion_workflow.merge(representation_id: item.id,
                                                                             position: index + 1))
        end
        item.save!
      end

      item
    end

  end

end
