# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Manifestation < Base
    self.table_name = 'manifestations'

    belongs_to :ingest_model

    belongs_to :representation_info
    belongs_to :access_right, optional: true

    belongs_to :from, class_name: 'Manifestation', inverse_of: :dependencies
    has_many :dependencies, class_name: 'Manifestation', foreign_key: :from_id, inverse_of: :from

    has_many :conversion_jobs, inverse_of: :manifestation

    validates :position, :label, presence: true, uniqueness: {scope: :ingest_model_id}

    def name
      label
    end

    def self.from_hash(hash, id_tags = [:ingest_model_id, :label])
      model_name = hash.delete(:ingest_model)
      query = model_name ? {name: model_name} : {id: hash[:ingest_model_id]}
      ingest_model = Teneo::DataModel::IngestModel.find_by!(query)
      hash[:ingest_model_id] = ingest_model.id

      conversion_jobs = hash.delete(:conversion_jobs)

      item = super(hash, id_tags) do |item, h|
        item.position = (position = h.delete(:position)) ? position : item.position = item.ingest_model.manifestations.count
        if (from = h.delete(:from))
          item.from = Teneo::DataModel::Manifestation.find_by!(ingest_model_id: hash[:ingest_model_id], label: from)
        end
        if (access_right = h.delete(:access_right))
          item.access_right = Teneo::DataModel::AccessRight.find_by!(name: access_right)
        end
        if (representation_info = h.delete(:representation_info))
          item.representation_info = Teneo::DataModel::RepresentationInfo.find_by!(name: representation_info)
        end
      end

      if conversion_jobs
        item.conversion_jobs.clear
        conversion_jobs.each_with_index do |conversion_job, index|
          item.conversion_jobs <<
              Teneo::DataModel::ConversionJob.from_hash(conversion_job.merge(manifestation_id: item.id,
                                                                             position: index + 1))
        end
        item.save!
      end

      item
    end

  end

end
