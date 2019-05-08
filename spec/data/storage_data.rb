# frozen_string_literal: true

module Storage

  # noinspection RubyStringKeysInHashInspection
  DATA = {
      org1: {name: 'ORG1', inst_code: 'ORG1'},
      org2: {name: 'ORG2', inst_code: 'ORG2'},
      storage1: {org: :org1, name: 'upload', protocol: 'nas', options: {'path' => '/upload/org1'}},
      storage2: {org: :org1, name: 'ftp_server', protocol: 'ftp', options: {'host' => 'ftp.org1.com'}},
      storage3: {org: :org2, name: 'upload', protocol: 'nas', options: {'path' => '/upload/org2'}},
  }

  LINKS = {
      storage1: {organization: :org1},
      storage2: {organization: :org1},
      storage3: {organization: :org2}
  }

  def self.create(spec, key)

  INIT = Proc.new do |_ctx, spec = {}|
    spec[:org1] = Teneo::DataModel::Organization::Operation::Create.(DATA[:org1])[model_param]
    spec[:org2] = Teneo::DataModel::Organization::Operation::Create.(DATA[:org2])[model_param]
    create = Proc.new do |k|
      data = DATA[k].dup
      org = data.delete(:org)
      result = Teneo::DataModel::Storage::Operation::Create.(data.merge(organization_id: spec[org].id))
      # puts result.inspect
      spec[k] = result[model_param]
    end
    create.(:storage1)
    create.(:storage2)
    create.(:storage3)
  end

  ITEMS = {
  }

  # noinspection RubyStringKeysInHashInspection
  TESTS = {
      index: {
          'get all' => {
              check_params: [DATA[:storage1],DATA[:storage2],DATA[:storage3]]
          },
          'get all again' => {
              check_params: [DATA[:storage1],DATA[:storage2],DATA[:storage3]]
          },
          'by name' => {
              options: {filter: {name: DATA[:storage1][:name]}},
              check_params: [DATA[:storage1],DATA[:storage3]]
          },
          'by protocol' => {
              options: {filter: {protocol: DATA[:storage1][:protocol]}},
              check_params: [DATA[:storage1], DATA[:storage3]]
          },
          'by name and protocol with match' => {
              options: {filter: {name: 'upload', protocol: 'nas'}},
              check_params: [DATA[:storage1],DATA[:storage3]]
          },
          'by name and protocol without match' => {
              options: {filter: {name: 'upload', protocol: 'ftp'}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              init: Proc.new do |_ctx, spec|
                spec[:org1] = Teneo::DataModel::Organization::Operation::Create.(DATA[:org1])[model_param]
                spec[:params] = spec[:params].merge(organization_id: spec[:org1].id)
              end,
              params: DATA[:storage1],
              check_params: DATA[:storage1]
          },
          'name missing' => {
              init: Proc.new do |_ctx, spec|
                spec[:org1] = Teneo::DataModel::Organization::Operation::Create.(DATA[:org1])[model_param]
                spec[:params] = spec[:params].merge(organization_id: spec[:org1].id)
              end,
              params: DATA[:storage1].reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique within its scope']}
          },
          'duplicate name with different organization' => {
              init: Proc.new do |ctx, spec|
                spec[:org1] = Teneo::DataModel::Organization::Operation::Create.(DATA[:org1])[model_param]
                ctx.subject.(*build_params(DATA[:storage1].merge(organization_id: spec[:org1].id)))
                spec[:org2] = Teneo::DataModel::Organization::Operation::Create.(DATA[:org2])[model_param]
                spec[:params] = spec[:params].merge(organization_id: spec[:org2].id)
              end,
              params: DATA[:storage2].merge(name: DATA[:storage1][:name])
          },
          'duplicate name with the same organization' => {
              init: Proc.new do |ctx, spec|
                spec[:org1] = Teneo::DataModel::Organization::Operation::Create.(DATA[:org1])[model_param]
                ctx.subject.(*build_params(DATA[:storage1].merge(organization_id: spec[:org1].id)))
                spec[:params] = spec[:params].merge(organization_id: spec[:org1].id)
              end,
              params: DATA[:storage2].merge(name: DATA[:storage1][:name]),
              failure: true,
              errors: {name: ['must be unique within its scope']}
          },
          'empty name' => {
              init: Proc.new do |_ctx, spec|
                spec[:org1] = Teneo::DataModel::Organization::Operation::Create.(DATA[:org1])[model_param]
                spec[:params] = spec[:params].merge(organization_id: spec[:org1].id)
              end,
              params: DATA[:storage1].merge(name: ''),
              failure: true,
              errors: {name: ['must be filled', 'must be unique within its scope']}
          }
      },
      retrieve: {
          'get item' => {
              init: Proc.new do |ctx, spec|
                spec[:org1] = Teneo::DataModel::Organization::Operation::Create.(DATA[:org1])[model_param]
                spec[:check_params] = spec[:check_params].merge(organization_id: spec[:org1].id)
                spec[:id] = ctx.create_class.(*build_params(DATA[:storage1].merge(organization_id: spec[:org1].id)))[model_param].id
              end,
              check_params: DATA[:storage1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with protocol and options' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx,spec)
                spec[:id] = spec[:storage1].id
              end,
              params: {protocol: 'gdrive', options: {'credentials_file' => 'credentials.json', 'path' => '/data'}},
              check_params: DATA[:storage1].merge(protocol: 'gdrive', options: {'credentials_file' => 'credentials.json', 'path' => '/data'}),
          },
          'name change' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx,spec)
                spec[:id] = spec[:storage1].id
              end,
              params: {name: 'cloud'},
              check_params: DATA[:storage1].merge(name: 'cloud'),
          },
          'duplicate name OK' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx,spec)
                spec[:id] = spec[:storage3].id
              end,
              params: {name: DATA[:storage2][:name]},
              check_params: DATA[:storage3].merge(name: DATA[:storage2][:name]),
          },
          'duplicate name not OK' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx,spec)
                spec[:id] = spec[:storage1].id
              end,
              params: {name: DATA[:storage2][:name]},
              failure: true,
              errors: {name: ['must be unique within its scope']},
          },
          'empty protocol' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx,spec)
                spec[:id] = spec[:storage1].id
              end,
              params: {protocol: ''},
              failure: true,
              errors: {protocol: ['must be filled']}
          },
          'empty options' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx,spec)
                spec[:id] = spec[:storage1].id
              end,
              params: {options: ''},
              failure: true,
              errors: {options: ['must be a hash']}
          },
          'remove protocol' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx,spec)
                spec[:id] = spec[:storage1].id
              end,
              params: {protocol: nil},
              failure: true,
              errors: {protocol: ['must be filled']}
          },
          'remove options' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx,spec)
                spec[:id] = spec[:storage1].id
              end,
              params: {options: nil},
              check_params: DATA[:storage1].merge(options: nil),
          }
      },
      delete: {
          'existing item' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx,spec)
                spec[:id] = spec[:storage1].id
              end,
              check_params: DATA[:storage1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
