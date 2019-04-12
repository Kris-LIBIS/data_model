# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class AccessRight < Base
    self.table_name = 'access_rights'

    has_many :ingest_models
    has_many :manifestations

  end

end
