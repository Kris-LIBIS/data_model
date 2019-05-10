# noinspection RubyStringKeysInHashInspection
# require 'support/hash_with_indifferent_access'
require 'support/symbolized_hash'

module DataModelData

  # DataHash = ActiveSupport::HashWithIndifferentAccess
  DataHash = SymbolizedHash

  # noinspection RubyStringKeysInHashInspection
  ITEMS = DataHash.new(
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
      tiff: {
          class: Teneo::DataModel::Format,
          data: {name: 'TIFF', category: 'IMAGE', mime_types: %w'image/tiff', extensions: %w'tif'}
      },
      jpeg: {
          class: Teneo::DataModel::Format,
          data: {name: 'JPEG', category: 'IMAGE', mime_types: %w'image/jpeg', extensions: %w'jpg'}
      },
      word: {
          class: Teneo::DataModel::Format,
          data: {
              name: 'WORD', category: 'TEXT', description: 'Microsoft Word Document (DOC)',
              mime_types: %w'application/msword application/vnd.msword application/vnd.ms-word',
              extensions: %w'doc wbk',
              puids: %w'fmt/609 fmt/39 x-fmt/273'
          }
      },
  )

end
