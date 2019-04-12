# frozen_string_literal: true
require 'teneo/data_model'

module Teneo::DataModel::Concept::Format::Operation

  class Index < Base

    step :model!

    def model!(_ctx, filter: nil, **)
      options[:model] = filter ? MODEL_CLASS.where(filter) : MODEL_CLASS.all
    end

  end

end
