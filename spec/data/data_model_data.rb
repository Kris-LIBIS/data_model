# frozen_string_literal: true

# require 'support/hash_with_indifferent_access'
require_relative '../support/symbolized_hash'
require 'set'

module DataModelData

  # DataHash = ActiveSupport::HashWithIndifferentAccess
  class DataHash < ::SymbolizedHash

    def reverse
      self.class.new(self.reverse_each.to_h)
    end

    def only(*classes)
      self.select do |_k, v|
        classes.include?(v[:class])
      end
    end

    def for(*classes)
      keys = only(*classes).keys
      keys += all_dependency_keys(*keys)
      keys.each_with_object(self.class.new) {|k, o| o[k] = self[k]}
    end

    def dependency_keys(*keys)
      keys.each_with_object(Set.new) do |key, dependencies|
        self.dig(key, :links)&.values&.each {|k| dependencies << k}
      end.to_a
    end

    def all_dependency_keys(*keys)
      dependencies = Set.new
      to_do = keys
      loop do
        # remove known dependencies to avoid infite recursion for circular dependencies
        # Note that circular dependencies are a problem anyway, we just do not want to crash here
        more_keys = dependency_keys(*to_do) - dependencies.to_a
        break if more_keys.empty?
        dependencies += (to_do = more_keys)
      end
      dependencies.to_a
    end

  end

  # noinspection RubyStringKeysInHashInspection
  ITEMS = DataHash.new(
      # Formats database
      # ################

      tiff: {
          class: Teneo::DataModel::Format,
          data: {name: 'TIFF', category: 'IMAGE', mimetypes: %w'image/tiff', extensions: %w'tif'}
      },
      jpeg: {
          class: Teneo::DataModel::Format,
          data: {name: 'JPEG', category: 'IMAGE', mimetypes: %w'image/jpeg', extensions: %w'jpg'}
      },
      word: {
          class: Teneo::DataModel::Format,
          data: {
              name: 'WORD', category: 'TEXT', description: 'Microsoft Word Document (DOC)',
              mimetypes: %w'application/msword application/vnd.msword application/vnd.ms-word',
              extensions: %w'doc wbk',
              puids: %w'fmt/609 fmt/39 x-fmt/273'
          }
      },

      # Code tables
      # ###########

      # Access Right
      access_right1: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'PUBLIC', ext_id: 'AR_PUBLIC'}
      },
      access_right2: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'PRIVATE', ext_id: 'AR_PRIVATE', description: 'Private access'}
      },
      access_right3: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'OPEN', ext_id: 'AR_PUBLIC'}
      },

      # Producer
      producer1: {
          class: Teneo::DataModel::Producer,
          data: {name: 'Ingester', ext_id: '1000', inst_code: 'INST1', agent: 'ingester', password: 'abc123'}
      },
      producer2: {
          class: Teneo::DataModel::Producer,
          data: {name: 'Producer', ext_id: '2000', inst_code: 'INST1', agent: 'producer', password: 'abc123', description: 'Regular producer'}
      },
      producer3: {
          class: Teneo::DataModel::Producer,
          data: {name: 'Ingester', ext_id: '3000', inst_code: 'INST2', agent: 'producer', password: 'abc123'}
      },

      # Material Flow
      material_flow1: {
          class: Teneo::DataModel::MaterialFlow,
          data: {name: 'Ingester', ext_id: '1000', inst_code: 'INST1'}
      },
      material_flow2: {
          class: Teneo::DataModel::MaterialFlow,
          data: {name: 'Collections', ext_id: '2000', inst_code: 'INST1', description: 'Create Collections'}
      },
      material_flow3: {
          class: Teneo::DataModel::MaterialFlow,
          data: {name: 'Ingester', ext_id: '3000', inst_code: 'INST2', description: 'Other ingester workflow'}
      },
      material_flow4: {
          class: Teneo::DataModel::MaterialFlow,
          data: {name: 'Ingester', ext_id: '2000', inst_code: 'ORG1'}
      },

      # Representation Info
      rep_info1: {
          class: Teneo::DataModel::RepresentationInfo,
          data: {name: 'ARCHIVE', preservation_type: 'PRESERVATION_MASTER', usage_type: 'VIEW'}
      },
      rep_info2: {
          class: Teneo::DataModel::RepresentationInfo,
          data: {name: 'VIEW_MAIN', preservation_type: 'DERIVATIVE_COPY', usage_type: 'VIEW', representation_code: 'HIGH'}
      },
      rep_info3: {
          class: Teneo::DataModel::RepresentationInfo,
          data: {name: 'VIEW', preservation_type: 'DERIVATIVE_COPY', usage_type: 'VIEW', representation_code: 'LOW'}
      },
      rep_info4: {
          class: Teneo::DataModel::RepresentationInfo,
          data: {name: 'THUMBNAIL', preservation_type: 'DERIVATIVE_COPY', usage_type: 'THUMBNAIL', representation_code: 'THUMBNAIL'}
      },

      # Retention Policy
      ret_policy1: {
          class: Teneo::DataModel::RetentionPolicy,
          data: {name: 'PERMANENT', ext_id: 'RP_NONE'}
      },
      ret_policy2: {
          class: Teneo::DataModel::RetentionPolicy,
          data: {name: '10_YEARS', ext_id: 'RP_10Y', description: 'Keep for at least 10 years'}
      },
      ret_policy3: {
          class: Teneo::DataModel::RetentionPolicy,
          data: {name: 'KEEP_FOREVER', ext_id: 'RP_NONE'}
      },


      # Users and Organizations
      # #######################

      # User
      user1: {
          class: Teneo::DataModel::User,
          data: {uuid: 'uuid1', email: 'user1@example.com'}
      },
      user2: {
          class: Teneo::DataModel::User,
          data: {uuid: 'uuid2', email: 'user2@example.com', first_name: 'John', last_name: 'Doe'}
      },
      user3: {
          class: Teneo::DataModel::User,
          data: {uuid: 'uuid3', email: 'user3@example.com', first_name: 'Jane', last_name: 'Doe'}
      },
      user4: {
          class: Teneo::DataModel::User,
          data: {uuid: 'uuid4', email: 'user4@example.com', first_name: 'John', last_name: 'Fox'}
      },

      # Organization
      org1: {
          class: Teneo::DataModel::Organization,
          data: {name: 'Organization 1', inst_code: 'INST1'}
      },
      org2: {
          class: Teneo::DataModel::Organization,
          data: {name: 'Organization 2', inst_code: 'INST2', ingest_dir: '/org2', description: 'organization 2'}
      },
      org3: {
          class: Teneo::DataModel::Organization,
          data: {name: 'Organization 3', inst_code: 'INST2', ingest_dir: '/org3'}
      },
      org4: {
          class: Teneo::DataModel::Organization,
          data: {name: 'Organization 4', inst_code: 'INST1', description: 'organization 4'}
      },

      # Storage
      storage1: {
          class: Teneo::DataModel::Storage,
          data: {name: 'upload', protocol: 'nas', options: {'path' => '/upload/org1'}},
          links: {organization_id: :org1}
      },
      storage2: {
          class: Teneo::DataModel::Storage,
          data: {name: 'ftp_server', protocol: 'ftp', options: {'host' => 'ftp.org1.com'}},
          links: {organization_id: :org1}
      },
      storage3: {
          class: Teneo::DataModel::Storage,
          data: {name: 'upload', protocol: 'nas', options: {'path' => '/upload/org2'}},
          links: {organization_id: :org2}
      },

      # Membership
      membership1: {
          class: Teneo::DataModel::Membership,
          data: {role: 'ingester'},
          links: {user_id: :user1, organization_id: :org1}
      },
      membership2: {
          class: Teneo::DataModel::Membership,
          data: {role: 'uploader'},
          links: {user_id: :user1, organization_id: :org2}
      },
      membership3: {
          class: Teneo::DataModel::Membership,
          data: {role: 'admin'},
          links: {user_id: :user2, organization_id: :org1}
      },
      membership4: {
          class: Teneo::DataModel::Membership,
          data: {role: 'admin'},
          links: {user_id: :user2, organization_id: :org2}
      },
      membership5: {
          class: Teneo::DataModel::Membership,
          data: {role: 'admin'},
          links: {user_id: :user1, organization_id: :org1}
      },

      # Ingest Agreements
      # #################
      agreement1: {
          class: Teneo::DataModel::IngestAgreement,
          data: {name: 'ingest 1'},
          links: {organization_id: :org1}
      },
      agreement2: {
          class: Teneo::DataModel::IngestAgreement,
          data: {name: 'ingest 2', project_name: 'project', collection_name: 'collection',
                 contact_ingest: ['contact'], contact_collection: ['contact'], contact_system: ['contact'],
                 collection_description: 'description', ingest_job_name: 'job', collector: 'collector'
          },
          links: {organization_id: :org1}
      },
      agreement3: {
          class: Teneo::DataModel::IngestAgreement,
          data: {name: 'ingest 3'},
          links: {organization_id: :org2}
      },

      # Ingest Models, Manifestations and ConversionJobs
      # ################################################

      # Ingest Models
      model1: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model 1'},
          links: {retention_policy_id: :ret_policy1, access_right_id: :access_right1}
      },
      model2: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model 2', description: 'ingest model 2', entity_type: 'entity type 1',
                 user_a: 'a', user_b: 'b', user_c: 'c', identifier: '123', status: 'stored'},
          links: {retention_policy_id: :ret_policy1, access_right_id: :access_right1}
      },
      model3: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model 3'},
          links: {retention_policy_id: :ret_policy1, access_right_id: :access_right1}
      },

      # Manifestations
      manifestation1: {
          class: Teneo::DataModel::Manifestation,
          data: {order: 1, name: 'manifestation 1', label: 'Label 1'},
          links: {ingest_model_id: :model1, representation_info_id: :rep_info1}
      },
      manifestation2: {
          class: Teneo::DataModel::Manifestation,
          data: {order: 3, name: 'manifestation 2', label: 'Label 2', optional: false},
          links: {ingest_model_id: :model1, representation_info_id: :rep_info2,  from_id: :manifestation1}
      },
      manifestation3: {
          class: Teneo::DataModel::Manifestation,
          data: {order: 2, name: 'manifestation 3', label: 'Label 1', optional: true},
          links: {ingest_model_id: :model2, representation_info_id: :rep_info1}
      },
      manifestation4: {
          class: Teneo::DataModel::Manifestation,
          data: {order: 4, name: 'manifestation 4', label: 'Label 2', optional: true},
          links: {ingest_model_id: :model2, representation_info_id: :rep_info2}
      },

      # Converters
      converter1: {
          class: Teneo::DataModel::Converter,
          data: {name: 'converter 1'},
      },
      converter2: {
          class: Teneo::DataModel::Converter,
          data: {name: 'converter 2', description: 'second converter'},
      },
      converter3: {
          class: Teneo::DataModel::Converter,
          data: {name: 'converter 3', class_name: 'Converter3', parameters: {param1: {descr: 'a parameter', type: 'integer'}}},
      },

      # ConversionJobs
      conversion_job1: {
          class: Teneo::DataModel::ConversionJob,
          data: {order: 1, config: {}},
          links: {manifestation_id: :manifestation1, converter_id: :converter1}
      },
      conversion_job2: {
          class: Teneo::DataModel::ConversionJob,
          data: {order: 2, config: {}},
          links: {manifestation_id: :manifestation1, converter_id: :converter2}
      },
      conversion_job3: {
          class: Teneo::DataModel::ConversionJob,
          data: {order: 1, config: {}},
          links: {manifestation_id: :manifestation2, converter_id: :converter3}
      },

      # Ingest Jobs
      # ###########

      # Packages and Items
      # ##################

  )

end
