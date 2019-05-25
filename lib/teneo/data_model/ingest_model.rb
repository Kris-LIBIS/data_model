# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestModel < Base
    self.table_name = 'ingest_models'

    belongs_to :ingest_agreement, inverse_of: :ingest_models

    has_many :manifestations, dependent: :destroy

    # self-reference #template
    has_many :derivatives, class_name: Teneo::DataModel::IngestModel.name, dependent: :destroy,
             inverse_of: :template,
             foreign_key: :template_id
    belongs_to :template, class_name: Teneo::DataModel::IngestModel.name,
               inverse_of: :derivatives

    # code tables
    belongs_to :retention_policy
    belongs_to :access_right

    validates :name, uniqueness: {scope: :ingest_agreement_id}
    validates :access_right_id, :retention_policy_id, presence: true
    validate :template_reference

    def template_reference
      return if template.nil?
      errors.add(:template_id, 'should be a template') unless template.ingest_agreement.nil?
    end

    def self.from_hash(hash)
      ingest_agreement = hash.delete('ingest_agreement')
      ingest_agreement = Teneo::DataModel::IngestAgreement.find_by!(name: ingest_agreement)
      hash['ingest_agreement_id'] = ingest_agreement.id
      super(hash, [:ingest_agreement_id, :name]) do |item, h|
        item.access_right = Teneo::DataModel::AccessRight.find_by!(name: h.delete(:access_right))
        item.retention_policy = Teneo::DataModel::RetentionPolicy.find_by!(name: h.delete(:retention_policy))
        item.save!
        if (manifestations = h.delete(:manifestations))
          item.manifestations.clear
          manifestations.each_with_index do |manifestation, index|
            manifestation[:ingest_model_id] = item.id
            manifestation[:position] = index + 1
            Teneo::DataModel::Manifestation.from_hash(manifestation)
          end
        end
      end
    end

  end

end
