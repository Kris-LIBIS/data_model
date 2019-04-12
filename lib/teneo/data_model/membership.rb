# frozen_string_literal: true
require_relative 'base'

module Teneo
  module DataModel
    # noinspection RailsParamDefResolve
    class Membership < Base
      self.table_name = 'memberships'

      belongs_to :user,
                 # class_name: 'Teneo::DataModel::User',
                 inverse_of: :memberships
      belongs_to :organizaion,
                 # class_name: 'Teneo::DataModel::Organization',
                 inverse_of: :memberships
    end
  end
end