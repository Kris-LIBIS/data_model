require "teneo/data_model/version"
require 'yaml'

module Teneo
  module DataModel
    autoload :User, 'teneo/data_model/user'
    autoload :Organization, 'teneo/data_model/organization'
    autoload :Membership, 'teneo/data_model/membership'
    autoload :Storage, 'teneo/data_model/storage'
    autoload :StorageType, 'teneo/data_model/storage_type'
    autoload :IngestAgreement, 'teneo/data_model/ingest_agreement'
    autoload :IngestModel, 'teneo/data_model/ingest_model'
    autoload :Representation, 'teneo/data_model/representation'
    autoload :ConversionWorkflow, 'teneo/data_model/conversion_workflow'
    autoload :ConversionTask, 'teneo/data_model/conversion_task'
    autoload :Converter, 'teneo/data_model/converter'
    autoload :IngestWorkflow, 'teneo/data_model/ingest_workflow'
    autoload :IngestStage, 'teneo/data_model/ingest_stage'
    autoload :StageWorkflow, 'teneo/data_model/stage_workflow'
    autoload :Task, 'teneo/data_model/task'
    autoload :StageTask, 'teneo/data_model/stage_task'
    autoload :Package, 'teneo/data_model/package'
    autoload :Item, 'teneo/data_model/item'
    autoload :StatusLog, 'teneo/data_model/status_log'
    autoload :Format, 'teneo/data_model/format'
    autoload :AccessRight, 'teneo/data_model/access_right'
    autoload :RetentionPolicy, 'teneo/data_model/retention_policy'
    autoload :RepresentationInfo, 'teneo/data_model/representation_info'
    autoload :MaterialFlow, 'teneo/data_model/material_flow'
    autoload :Producer, 'teneo/data_model/producer'

    autoload :Parameter, 'teneo/data_model/parameter'
    autoload :ParameterReference, 'teneo/data_model/parameter_reference'
    autoload :WithParameters, 'teneo/data_model/with_parameters'

    autoload :SeedLoader, 'teneo/data_model/seed_loader'

    def self.root
      File.expand_path('../..', __dir__)
    end

    def self.migrations_path
      File.join(root, 'db', 'migrate')
    end

    def self.connect_db(environment = nil)
      environment ||= ENV['RUBY_ENV'] || "development"
      db_config_file  = File.join(root, 'config', 'database.yml')
      db_config       = YAML::load_file(db_config_file)[environment.to_s]
      # noinspection RubyStringKeysInHashInspection
      db_config_admin = db_config.merge({'database' => 'postgres', 'schema_search_path' => 'public'})
      ActiveRecord::Base.establish_connection(db_config_admin)
    end
  end
end

# require 'teneo/data_model/concept/autoload'
