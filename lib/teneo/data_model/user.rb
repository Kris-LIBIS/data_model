# frozen_string_literal: true
require 'teneo-data_model'
require_relative 'base'

module Teneo
  module DataModel
    # noinspection RailsParamDefResolve
    class User < Base
      self.table_name = 'users'

      has_many :memberships,
               # class_name: Teneo::DataModel::Membership,
               dependent: :destroy,
               inverse_of: :user

      # @param [Hash] hash
      def self.from_hash(hash)
        super(hash, [:email]) do |item, h|
          if (roles = h.delete[:roles])
            roles.each do |role|
              organization_name = role[:organization]
              org = Organization.find_by(name: organization_name)
              puts "Could not find organization '#{organization_name}'" unless org
              role_code = role[:role]
              if %w(admin uploader ingester).include? role_code
                item.add_role(role_code, org) if org
              else
                puts "Invalid role '#{role_code}'"
              end
            end
          end
        end
      end

      # sanitize email and username
      before_validation do
        self.email = self.email.to_s.downcase
      end

      validates_presence_of :email
      validates_uniqueness_of :email, case_sensitive: false
      validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP

      # @param [Organization] organization
      # @return [Array<String>]
      def roles_for(organization)
        self.memberships.where(organization: organization).map(&:role) rescue []
      end

      # @param [String] role
      # @return [Array<Organization>]
      def organizations_for(role)
        self.memberships.where(role: role).map(&:organization) rescue []
      end

      # @param [String] role
      # @param [Organization] organization
      # @return [boolean]
      def is_authorized?(role, organization)
        self.roles_for(organization).include?(role)
      end

      # @param [String] role
      # @param [Organization] organization
      # @return [Membership]
      def add_role(role, organization)
        self.memberships.build(organization: organization, role: role)
      end

      # @param [String] role
      # @param [Organization] organization
      def del_role(role, organization)
        m = self.memberships.find_by(organization: organization, role: role)
        m&.destroy!
      end

      # @return [Hash<Organization, Array<String>>]
      def member_organizations
        # noinspection RubyResolve
        self.memberships.reduce({}) do |h, m|
          h[m.organization] ||= []
          h[m.organization].push(m.role)
          h
        end
      end

    end
  end
end