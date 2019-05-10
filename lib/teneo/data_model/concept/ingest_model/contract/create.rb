# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::IngestModel::Contract

  class Create < Base

    property :name
    property :description
    property :entity_type
    property :user_a
    property :user_b
    property :user_c
    property :identifier
    property :status
    property :ingest_agreement_id
    property :retention_policy_id
    property :access_right_id

    validation name: :default, inherit: true do

      required(:name).filled(:str?) {unique? :name}
      optional(:description).maybe(:str?)
      optional(:entity_type).maybe(:str?)
      optional(:user_a).maybe(:str?)
      optional(:user_b).maybe(:str?)
      optional(:user_c).maybe(:str?)
      optional(:identifier).maybe(:str?)
      optional(:status).maybe(:str?)
      optional(:ingest_agreement_id).maybe {model_exist? Teneo::DataModel::IngestAgreement}
      required(:retention_policy_id).filled {model_exist? Teneo::DataModel::RetentionPolicy}
      required(:access_right_id).filled {model_exist? Teneo::DataModel::AccessRight}

    end

    # TODO: more sanity validations:
    # - ingest agreement link is unique (only 1 ingest model links to given ingest agreement)
    # - support for templates & derivates, including no delete if derivates exist

  end

end
