# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class Converter < Base
    self.table_name = 'converters'

    has_many :conversion_jobs
  end

end
