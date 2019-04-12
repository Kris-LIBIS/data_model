# frozen_string_literal: true
require 'teneo/data_model'

module Teneo::DataModel::Concept::Format::Operation

  class Create < Base

    step Nested(Present)
    step Contract.Validate
    step Contract.Persist

  end

end
