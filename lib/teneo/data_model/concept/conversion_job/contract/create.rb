# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::ConversionJob::Contract

  class Create < Base

    property :order
    property :config
    property :manifestation_id
    property :converter_id

    validation name: :default, inherit: true do
      required(:order).filled(:int?)
      optional(:config).maybe(:filled?, :hash?)
      required(:manifestation_id).filled {model_exist?(Teneo::DataModel::Manifestation)}
      required(:converter_id).filled {model_exist?(Teneo::DataModel::Converter)}
    end

  end

end
