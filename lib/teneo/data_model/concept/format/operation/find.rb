# frozen_string_literal: true
require 'teneo/data_model'

module Teneo::DataModel::Concept::Format::Operation

  class Find < Base

    # step Rescue(ActiveRecord::RecordNotFound, handler: :not_found!) {
    step Rescue(ActiveRecord::RecordNotFound) {
      step Model MODEL_CLASS, :find
    }

    failure :not_found!#, Output(:failure) => End(:not_found)

    def not_found!(ctx, params:, **)
      ctx[:errors] ||= []
      ctx[:errors] << "Instance of #{MODEL_CLASS} with id '#{params[:id]}' not found."
    end

  end

end
