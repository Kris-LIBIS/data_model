# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Converter::Contract

  class Create < Base

    property :name
    property :description
    property :class_name
    property :parameters

    validation name: :default, inherit: true do
      required(:name).filled(:str?)
      optional(:description).maybe(:filled?, :str?)
      optional(:class_name).maybe(:filled?, :str?)
      optional(:parameters).maybe(:filled?, :hash?)
    end

  end

end
