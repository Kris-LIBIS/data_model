# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::MaterialFlow::Contract

  class Create < Base

    property :name
    property :ext_id
    property :inst_code
    property :description

    validation name: :default, inherit: true, with: {form: true} do

      required(:name).filled(:str?) {unique_scope? [:inst_code, :name]}
      required(:ext_id).filled(:str?)
      required(:inst_code).filled(:str?)
      optional(:description).maybe(:filled?, :str?)

    end

  end

end
