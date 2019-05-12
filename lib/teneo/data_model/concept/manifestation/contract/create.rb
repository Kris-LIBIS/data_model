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

      required(:name).filled(:str?) {unique_scope? [:ingest_model_id, :name]}
      required(:order).filled(:int?) {unique_scope? [:ingest_model_id, :order]}
      required(:label).filled(:str?) {unique_scope? [:ingest_model_id, :label]}
      optional(:optional).maybe(:bool?)

      optional(:access_right_id).maybe {model_exist? Teneo::DataModel::AccessRight}
      required(:representation_info_id).filled {model_exist? Teneo::DataModel::RepresentationInfo}

      optional(:from_id).maybe {model_exist?(Teneo::DataModel::Manifestation) & from_with_lower_order? & matches_ingest_model?}

      optional(:ingest_model_id).maybe {model_exist? Teneo::DataModel::IngestModel}

    end

    # TODO: more sanity validations:
    # - link to self not allowed
    # - no delete if dependencies exist

  end

end
