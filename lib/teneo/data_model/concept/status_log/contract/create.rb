# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::StatusLog::Contract

  class Create < Base

    property :task
    property :status
    property :progress
    property :max

    property :item_id

    validation name: :default, inherit: true do

      required(:task).filled(:str?)
      required(:status).filled(:str?)
      required(:progress).filled(:integer?)
      required(:max).filled(:integer?)

      optional(:item_id).maybe {model_exist?(Teneo::DataModel::Item)}

    end

  end

end
