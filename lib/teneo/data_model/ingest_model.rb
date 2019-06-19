# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestModel < Base
    self.table_name = 'ingest_models'

    belongs_to :ingest_agreement, inverse_of: :ingest_models

    has_many :representations, dependent: :destroy

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

    def self.from_hash(hash, id_tags = [:ingest_agreement_id, :name])
      agreement_name = hash.delete(:ingest_agreement)
      query = agreement_name ? {name: agreement_name} : {id: hash[:ingest_agreement_id]}
      ingest_agreement = Teneo::DataModel::IngestAgreement.find_by!(query)
      hash[:ingest_agreement_id] = ingest_agreement.id

      representations = hash.delete(:representations)

      item = super(hash, id_tags) do |item, h|
        item.access_right = Teneo::DataModel::AccessRight.find_by!(name: h.delete(:access_right))
        item.retention_policy = Teneo::DataModel::RetentionPolicy.find_by!(name: h.delete(:retention_policy))
      end

      if representations
        item.representations.clear
        representations.each_with_index do |representation, index|
          representation[:ingest_model_id] = item.id
          representation[:position] = index + 1
          Teneo::DataModel::Representation.from_hash(representation)
        end
        item.save!
      end

      item
    end

  end

end
