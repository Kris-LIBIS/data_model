# frozen_string_literal: true

module Teneo::DataModel::IngestModel::Contract

  autoload :Base, 'teneo/data_model/concept/ingest_model/contract/base'
  autoload :Create, 'teneo/data_model/concept/ingest_model/contract/create'
  autoload :Update, 'teneo/data_model/concept/ingest_model/contract/update'

end

module Teneo::DataModel::IngestModel::Operation

  MODEL_CLASS = 'Teneo::DataModel::IngestModel'
  include Teneo::DataModel::Concept::CRUD

end
