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
      belongs_to :organization,
                 # class_name: 'Teneo::DataModel::Organization',
                 inverse_of: :memberships

      validate :unique_role

      def unique_role
        query = Membership.where(user: user, organization: organization, role: role)
        query = query.where.not(id: id) if id # exclude self if persisted
        errors.add(:role, 'should be unique for a given user and organization') unless query.size == 0
      end

    end
  end
end