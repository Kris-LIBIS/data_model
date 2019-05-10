# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Manifestation::Contract

  class Create < Base

    property :order
    property :name
    property :label
    property :optional

    property :access_right_id
    property :representation_info_id

    property :from_id

    property :ingest_model_id

    validation name: :default, inherit: true do

      required(:name).filled(:str?)
      required(:order).filled(:int?)
      required(:label).filled(:str?)
      optional(:optional).maybe(:bool?)

      optional(:access_right_id).maybe {model_exist? Teneo::DataModel::AccessRight}
      required(:representation_info_id).filled {model_exist? Teneo::DataModel::RepresentationInfo}

      optional(:from_id).maybe {model_exist? Teneo::DataModel::Manifestation}

      optional(:ingest_agreement_id).maybe {model_exist? Teneo::DataModel::IngestAgreement}

    end

    # TODO: more sanity validations:
    # - from links to manifestation of same model
    # - from links to manifestation of lower order
    # - link to self not allowed
    # - no delete if dependencies exist

  end

end
