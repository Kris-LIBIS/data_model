# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Producer::Contract

  class Create < Base

    property :name
    property :ext_id
    property :inst_code
    property :agent
    property :password
    property :description

    validation name: :default, inherit: true, with: {form: true} do

      required(:name).filled(:str?) {unique_scope? [:inst_code, :name]}
      required(:ext_id).filled(:str?)
      required(:inst_code).filled(:str?)
      required(:agent).filled(:str?)
      required(:password).filled(:str?)
      optional(:description).maybe(:filled?, :str?)

    end

  end

end
