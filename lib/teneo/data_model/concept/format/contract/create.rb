# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Format::Contract

  class Create < Base

    property :name
    property :category
    property :description
    property :mimetypes
    property :puids
    property :extensions

    validation name: :default, inherit: true do
      required(:name).filled(:str?) {unique?(:name)}
      required(:category).filled(:str?, included_in?: %w'IMAGE AUDIO VIDEO TEXT TABULAR PRESENTATION ARCHIVE EMAIL OTHER')
      optional(:description).maybe(:str?, :filled?)
      required(:mimetypes).filled {array_of? String}
      optional(:puids).maybe(:filled?) {array_of? String}
      required(:extensions).filled {array_of? String}
    end

  end

end
