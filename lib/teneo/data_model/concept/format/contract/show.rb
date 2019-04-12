# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Concept::Format::Contract

  class Show < Base

    property :id

    validation :default, inherit: true do
      required(:id).filled(exists?: :id)
    end

  end

end
