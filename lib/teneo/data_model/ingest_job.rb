# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class IngestJob < Base
    self.table_name = 'ingest_jobs'

    belongs_to :ingest_agreement, inverse_of: :ingest_jobs

    has_many :ingest_tasks
    has_many :parameter_defs, as: :with_parameters, class_name: 'Teneo::DataModel::ParameterDef'

    validates :name, presence: true

    def self.from_hash(hash, id_tags = [:ingest_agreement_id, :name])
      agreement_name = hash.delete(:ingest_agreement)
      query = agreement_name ? {name: agreement_name} : {id: hash[:ingest_agreement_id]}
      ingest_agreement = Teneo::DataModel::IngestAgreement.find_by!(query)
      hash[:ingest_agreement_id] = ingest_agreement.id

      params = hash.delete(:parameters)

      item = super(hash, id_tags) do |item, h|
        if (workflow = h.delete(:workflow))
          item.workflow = Teneo::DataModel::Workflow.find_by!(name: workflow)
        end
      end

      if params
        item.parameter_defs.clear
        params.each do |name, definition|
          item.parameter_defs <<
              Teneo::DataModel::ParameterDef.from_hash(definition.merge(name: name,
                                                                        with_parameters_id: item.id,
                                                                        with_parameters_type: item.class.name))
        end
        item.save!
      end

      item
    end

  end

end
