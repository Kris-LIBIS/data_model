# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Item::Contract

  class Create < Base

    property :item_type
    property :name
    property :label

    property :parent_id

    property :package_id

    validation name: :default, inherit: true do

      required(:item_type).filled(:str?)
      required(:name).filled(:str?)
      required(:label).filled(:str?) {unique_scope? [:ingest_model_id, :label]}

      optional(:parent_id).maybe {model_exist?(Teneo::DataModel::Item) & matches_package?}

      optional(:package_id).maybe {model_exist? Teneo::DataModel::Package}

    end

    # TODO: more sanity validations:
    # - link to self not allowed
    # - no delete if dependencies exist

  end

end
