# frozen_string_literal: true

module Teneo::DataModel::IngestAgreement::Contract

  autoload :Base, 'teneo/data_model/concept/ingest_agreement/contract/base'
  autoload :Create, 'teneo/data_model/concept/ingest_agreement/contract/create'
  autoload :Update, 'teneo/data_model/concept/ingest_agreement/contract/update'

end

module Teneo::DataModel::IngestAgreement::Operation

  MODEL_CLASS = 'Teneo::DataModel::IngestAgreement'
  include Teneo::DataModel::Concept::CRUD

end
