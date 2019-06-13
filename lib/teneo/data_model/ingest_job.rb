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

    has_many :values, as: :with_values, class_name: 'Teneo::DataModel::ParameterValue'

    validates :stage, presence: true, inclusion: {in: STAGE_LIST}

    def self.from_hash(hash, id_tags = [:ingest_agreement_id, :stage])
      agreement_name = hash.delete(:ingest_agreement)
      query = agreement_name ? {name: agreement_name} : {id: hash[:ingest_agreement_id]}
      ingest_agreement = Teneo::DataModel::IngestAgreement.find_by!(query)
      hash[:ingest_agreement_id] = ingest_agreement.id

      params = hash.delete(:values)

      item = super(hash, id_tags) do |item, h|
        if (workflow = h.delete(:workflow))
          item.workflow = Teneo::DataModel::Workflow.find_by!(name: workflow)
        end
        item.retention_policy = Teneo::DataModel::RetentionPolicy.find_by!(name: h.delete(:retention_policy))
      end

      if params
        item.values.clear
        params.each do |name, value|
          item.values << Teneo::DataModel::ParameterValue.from_hash(name: name, value: value,
                                                                    with_values_id: item.id,
                                                                    with_values_type: item.class.name)
        end
        item.save!
      end

      item
    end

  end

end
