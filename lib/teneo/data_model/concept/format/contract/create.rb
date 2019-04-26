# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Format::Contract

  class Create < Base

    property :name
    property :category
    property :description
    property :mime_types
    property :puids
    property :extensions

    validation name: :default, inherit: true do
      required(:name).filled(:str?) {unique?(:name)}
      required(:category).filled(:str?, included_in?: %w'IMAGE AUDIO VIDEO TEXT TABULAR PRESENTATION ARCHIVE EMAIL OTHER')
      optional(:description).maybe(:str?, min_size?: 1)
      required(:mime_types).filled(:array?, min_size?: 1) {array_of? String}
      optional(:puids).maybe(:array?, min_size?: 1) {array_of? String}
      required(:extensions).filled(:array?, min_size?: 1) {array_of? String}
    end

  end

end
