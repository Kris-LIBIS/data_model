# frozen_string_literal: true
require 'teneo/data_model'

module Teneo::DataModel::Concept::Format::Operation

  class Edit < Base

    step Nested(Find)
    step Contract.Build constant: Teneo::DataModel::Concept::Format::Contract::Update

  end

end
