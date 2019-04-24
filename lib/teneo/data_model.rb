require "teneo/data_model/version"

module Teneo
  module DataModel
    autoload :User, 'teneo/data_model/user'
    autoload :Organization, 'teneo/data_model/organization'
    autoload :Membership, 'teneo/data_model/membership'
    autoload :Format, 'teneo/data_model/format'
    autoload :AccessRight, 'teneo/data_model/access_right'

    def self.root
      File.expand_path('../..', __dir__)
    end

    def self.migrations_path
      File.join(root, 'db', 'migrate')
    end
  end
end

require 'teneo/data_model/concept/autoload'
