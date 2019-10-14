# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Run < Base

    include Libis::Workflow::Run

    self.table_name = 'runs'

    belongs_to :package
    has_many :status_logs

    def job
      package
    end

  end

end
