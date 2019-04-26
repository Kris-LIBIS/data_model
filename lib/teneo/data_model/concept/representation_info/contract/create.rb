# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::RepresentationInfo::Contract

  class Create < Base

    property :name
    property :preservation_type
    property :usage_type
    property :representation_code

    validation name: :default, inherit: true do
      required(:name).filled(:str?) {unique? :name}
      required(:preservation_type).filled(:str?)
      required(:usage_type).filled(:str?)
      optional(:representation_code).maybe(:str?, min_size?: 1)
    end

  end

end
