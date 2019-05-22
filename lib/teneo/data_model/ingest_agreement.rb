# frozen_string_literal: true
require_relative 'base'
require 'active_support/core_ext/object/with_options'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestAgreement < Base
    self.table_name = 'ingest_agreements'

    with_options dependent: :destroy, inverse_of: :ingest_agreement do |model|
      model.has_one :ingest_model
      model.has_many :ingest_jobs
      model.has_many :packages
    end

    with_options inverse_of: :ingest_agreements do |model|
      model.belongs_to :organization
      model.belongs_to :material_flow, -> { where inst_code: self.organization.inst_code }
      model.belongs_to :producer, -> { where inst_code: self.organization.inst_code }
    end

    array_field :contact_ingest
    array_field :contact_collection
    array_field :contact_system

  end

end
