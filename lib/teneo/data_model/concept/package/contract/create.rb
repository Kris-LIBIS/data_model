# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Package::Contract

  class Create < Base

    property :name
    property :stage
    property :status
    property :base_dir
    property :ingest_agreement_id

    validation name: :default, inherit: true do

      required(:name).filled(:str?)
      required(:stage).filled(:str?) {unique_scope? [:ingest_agreement_id, :stage]}
      required(:status).filled(:str?)
      required(:base_dir).filled(str?)
      required(:ingest_agreement_id).filled {model_exist? Teneo::DataModel::IngestAgreement}

    end

  end

end
