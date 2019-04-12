# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  class RetentionPolicy < Base
    self.table_name = 'retention_policies'
  end

end
