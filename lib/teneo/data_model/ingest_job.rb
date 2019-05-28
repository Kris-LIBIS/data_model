# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestJob < Base
    self.table_name = 'ingest_jobs'

    STAGE_LIST = %w'PreProcess PreIngest Ingest PostIngest'

    with_options inverse_of: :ingest_jobs do |model|
      model.belongs_to :ingest_agreement
      model.belongs_to :workflow
    end

    validates :stage, presence: true, inclusion: {in: STAGE_LIST}

    def self.from_hash(hash, id_tags = [:ingest_agreement_id, :stage])
      ingest_agreement = hash.delete('ingest_agreement')
      ingest_agreement = Teneo::DataModel::IngestAgreement.find_by!(name: ingest_agreement)
      hash['ingest_agreement_id'] = ingest_agreement.id
      values = h.delete('values')
      item = super(hash, id_tags) do |item, h|
        if (workflow = h.delete(:workflow))
          item.workflow = Teneo::DataModel::Workflow.find_by!(name: workflow)
        end
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
      values.each do |value|
        value['with_value_id'] = item.id
        value['with_value_type'] = item.class.name
        item.values << Teneo::DataModel::ParameterValue.from_hash(value)
      end
    end

  end

end
