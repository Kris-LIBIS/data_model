require "teneo/data_model/version"

module Teneo
  module DataModel
    autoload :User, 'teneo/data_model/user'
    autoload :Organization, 'teneo/data_model/organization'
    autoload :Membership, 'teneo/data_model/membership'
    autoload :Storage, 'teneo/data_model/storage'
    autoload :IngestAgreement, 'teneo/data_model/ingest_agreement'
    autoload :Format, 'teneo/data_model/format'
    autoload :AccessRight, 'teneo/data_model/access_right'
    autoload :RetentionPolicy, 'teneo/data_model/retention_policy'
    autoload :RepresentationInfo, 'teneo/data_model/representation_info'
    autoload :MaterialFlow, 'teneo/data_model/material_flow'
    autoload :Producer, 'teneo/data_model/producer'

    def self.root
      File.expand_path('../..', __dir__)
    end

    def self.migrations_path
      File.join(root, 'db', 'migrate')
    end
  end
end

require 'teneo/data_model/concept/autoload'
