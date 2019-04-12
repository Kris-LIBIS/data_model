# frozen_string_literal: true
require 'teneo/data_model'

module Teneo::DataModel::Concept::Format::Operation

  class Delete < Base

    step Nested(Show)
    step :delete!

    def delete!(_ctx, model:, **)
      model.destroy
    end

  end

end
