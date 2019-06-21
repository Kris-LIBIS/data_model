# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestAgreement < Base
    self.table_name = 'ingest_agreements'

    with_options dependent: :destroy, inverse_of: :ingest_agreement do |model|
      model.has_many :ingest_models
      model.has_many :ingest_jobs
      model.has_many :packages
    end

    with_options inverse_of: :ingest_agreements do |model|
      model.belongs_to :organization
      model.belongs_to :material_flow
      model.belongs_to :producer
    end

    accepts_nested_attributes_for :material_flow
    accepts_nested_attributes_for :producer

    array_field :contact_ingest
    array_field :contact_collection
    array_field :contact_system

    validates :name, presence: true
    validates_each :producer, :material_flow do |record, attr, value|
      record.errors.add attr, 'organization does not match' unless value.nil? || value.inst_code == record.organization.inst_code
    end

    def self.from_hash(hash, id_tags = [:organization_id, :name])
      org_name = hash.delete(:organization)
      query = org_name ? {name: org_name} : {id: hash[:organization_id]}
      organization = record_finder Teneo::DataModel::Organization, query
      hash[:organization_id] = organization.id
      ingest_models = hash.delete(:ingest_models)
      ingest_jobs = hash.delete(:ingest_jobs)
      item = super(hash, id_tags) do |item, h|
        if (producer = h.delete(:producer))
          item.producer = record_finder Teneo::DataModel::Producer, inst_code: organization.inst_code, name: producer
        end
        if (material_flow = h.delete(:material_flow))
          item.material_flow =record_finder Teneo::DataModel::MaterialFlow, inst_code: organization.inst_code, name: material_flow
        end
      end
      if ingest_models
        item.ingest_models.clear
        ingest_models.each do |ingest_model|
          item.ingest_models << Teneo::DataModel::IngestModel.from_hash(ingest_model.merge(ingest_agreement_id: item.id))
        end
        item.save!
      end
      if ingest_jobs
        item.ingest_jobs.clear
        ingest_jobs.each do |ingest_job|
          item.ingest_jobs << Teneo::DataModel::IngestJob.from_hash(ingest_job.merge(ingest_agreement_id: item.id))
        end
        item.save!
      end
      item
    end

  end

end
