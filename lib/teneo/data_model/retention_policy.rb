# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  class RetentionPolicy < Base
    self.table_name = 'retention_policies'

    validates :name, :ext_id,presence: true
    validates :name, uniqueness: true
  end

end
