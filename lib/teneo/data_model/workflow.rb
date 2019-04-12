# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class Workflow < Base
    self.table_name = 'workflows'

    has_many :ingest_jobs, inverse_of: :workfow

  end

end
