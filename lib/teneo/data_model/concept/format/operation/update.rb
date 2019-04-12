# frozen_string_literal: true
require 'teneo/data_model'

module Teneo::DataModel::Concept::Format::Operation

  class Update < Base

    step Nested(Edit)
    step Contract.Validate
    step Contract.Persist

  end

end
