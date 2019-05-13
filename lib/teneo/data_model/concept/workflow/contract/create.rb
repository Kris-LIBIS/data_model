# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Workflow::Contract

  class Create < Base

    property :name
    property :stage
    property :description
    property :tasks
    property :parameters

    validation name: :default, inherit: true do
      required(:name).filled(:str?)
      required(:stage).filled(:str?)
      optional(:description).maybe(:filled?, :str?)
      optional(:tasks).maybe(:filled?, :hash?)
      optional(:parameters).maybe(:filled?, :hash?)
    end

  end

end
