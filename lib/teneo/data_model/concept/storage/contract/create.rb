# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Storage::Contract

  class Create < Base

    property :organization_id
    property :name
    property :protocol
    property :options

    validation name: :default, inherit: true do
      required(:organization_id).filled {model_exist? Teneo::DataModel::Organization}
      required(:name).filled(:str?) {unique_scope? [:organization_id, :name]}
      required(:protocol).filled(:str?)
      optional(:options).maybe(:hash?, :filled?)
    end

  end

end
