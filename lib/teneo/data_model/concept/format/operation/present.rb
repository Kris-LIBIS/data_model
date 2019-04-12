# frozen_string_literal: true
require 'teneo/data_model'

module Teneo::DataModel::Concept::Format::Operation

  class Present < Base

    step Model(MODEL_CLASS, :new)
    # step Model(MODEL_CLASS), :new
    step Contract.Build(constant: Teneo::DataModel::Concept::Format::Contract::Create)

  end

end
