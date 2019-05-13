# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::IngestJob::Contract

  class Create < Base

    property :stage
    property :config
    property :ingest_agreement_id
    property :workflow_id

    validation name: :default, inherit: true do

      required(:stage).filled(:str?) {unique_scope? [:ingest_agreement_id, :stage]}
      optional(:config).maybe(:filled?, :hash?)
      required(:ingest_agreement_id).filled {model_exist? Teneo::DataModel::IngestAgreement}
      required(:workflow_id).filled {model_exist? Teneo::DataModel::Workflow}

    end

  end

end
