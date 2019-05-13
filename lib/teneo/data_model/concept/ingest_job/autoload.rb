# frozen_string_literal: true

module Teneo::DataModel::IngestJob::Contract

  autoload :Base, 'teneo/data_model/concept/ingest_job/contract/base'
  autoload :Create, 'teneo/data_model/concept/ingest_job/contract/create'
  autoload :Update, 'teneo/data_model/concept/ingest_job/contract/update'

end

module Teneo::DataModel::IngestJob::Operation

  MODEL_CLASS = 'Teneo::DataModel::IngestJob'
  include Teneo::DataModel::Concept::CRUD

end
