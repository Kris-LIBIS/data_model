# frozen_string_literal: true
require_relative 'base'
require 'active_support/core_ext/object/with_options'

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

    def self.from_hash(hash)
      organization = hash.delete('organization')
      organization = Teneo::DataModel::Organization.find_by(name: organization)
      hash['organization_id'] = organization.id
      producer = hash.delete('producer')
      producer = Teneo::DataModel::Producer.find_by(inst_code: organization.inst_code, name: producer) if producer
      material_flow = hash.delete('material_flow')
      material_flow = Teneo::DataModel::MaterialFlow.find_by(inst_code: organization.inst_code, name: material_flow) if material_flow
      item = super(hash, [:organization_id, :name])
      item.producer = producer if producer
      item.material_flow = material_flow if material_flow
      item.save!
    end


  end

end
