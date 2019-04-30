# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Organization::Contract

  class Create < Base

    property :name
    property :inst_code
    property :ingest_dir
    property :description
    property :upload_areas

    validation name: :default, inherit: true do
      required(:name).filled(:str?) {unique? :name}
      optional(:inst_code).maybe(:str?, :filled?)
      optional(:ingest_dir).maybe(:str?, :filled?)
      optional(:description).maybe(:str?, :filled?)
      optional(:upload_areas).maybe(:hash?)
    end

  end

end
