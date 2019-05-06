# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Organization::Contract

  class Create < Base

    property :id
    property :name
    property :inst_code
    property :ingest_dir
    property :description

    validation name: :default, inherit: true do
      required(:name).filled(:str?) {unique? :name}
      required(:inst_code).filled(:str?)
      optional(:ingest_dir).maybe(:str?, :filled?)
      optional(:description).maybe(:str?, :filled?)
    end

  end

end
