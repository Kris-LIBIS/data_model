# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::AccessRight::Contract

  class Create < Base

    property :name
    property :ext_id
    property :description

    validation name: :default, inherit: true do
      required(:name).filled(:str?) {unique? :name}
      required(:ext_id).filled(:str?)
      optional(:description).maybe(:str?, :filled?)
    end

  end

end
