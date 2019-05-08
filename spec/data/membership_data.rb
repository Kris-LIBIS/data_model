# frozen_string_literal: true

module Membership

  # noinspection RubyStringKeysInHashInspection
  ITEMS = {
      org1: {
          class: Teneo::DataModel::Organization,
          data: {name: 'ORG1', inst_code: 'ORG1'}
      },
      org2: {
          class: Teneo::DataModel::Organization,
          data: {name: 'ORG2', inst_code: 'ORG2'}
      },
      user1: {
          class: Teneo::DataModel::User,
          data: {uuid: '4689fc7b-c949-4904-bc5b-99fec47882f5', email: 'user1@example.com'}
      },
      user2: {
          class: Teneo::DataModel::User,
          data: {uuid: '3c1d6d36-e618-4a38-bebd-8db6b6d3d76f', email: 'user2@example.com'}
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
  }

  # noinspection RubyStringKeysInHashInspection
  TESTS = {
      index: {
          'get all' => {
              check_params: [ITEMS[:membership1], ITEMS[:membership2], ITEMS[:membership3], ITEMS[:membership4]]
          },
          'by role' => {
              options: {filter: {role: 'admin'}},
              check_params: [ITEMS[:membership3], ITEMS[:membership4]]
          },
          'by organization_id' => {
              options: Proc.new {|_ctx, spec| {filter: {organization_id: spec[:org1].id}}},
              check_params: [ITEMS[:membership1], ITEMS[:membership3]]
          },
          'by user_id' => {
              options: Proc.new {|_ctx, spec| {filter: {user_id: spec[:user1].id}}},
              check_params: [ITEMS[:membership1], ITEMS[:membership2]]
          },
          'by user_id and role with match' => {
              options: Proc.new {|_ctx, spec| {filter: {user_id: spec[:user2].id, role: 'admin'}}},
              check_params: [ITEMS[:membership3], ITEMS[:membership4]]
          },
          'by user_id and role without match' => {
              options: Proc.new {|_ctx, spec| {filter: {user_id: spec[:user1].id, role: 'admin'}}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              init: Proc.new do |ctx, spec|
                spec[:org1] = ctx.create_item(spec, ITEMS[:org1])
                spec[:user1] = ctx.create_item(spec, ITEMS[:user1])
              end,
              params: ITEMS[:membership1],
              check_params: ITEMS[:membership1]
          },
          'role missing' => {
              init: Proc.new do |ctx, spec|
                spec[:org1] = ctx.create_item(spec, ITEMS[:org1])
                spec[:user1] = ctx.create_item(spec, ITEMS[:user1])
              end,
              params: ITEMS[:membership1].merge(data: ITEMS[:membership1][:data].reject! {|k| k == :role}),
              failure: true,
              errors: {name: ['must be filled', 'must be unique within its scope']}
          },
          'duplicate role with different organization' => {
              init: Proc.new do |ctx, spec|
                ctx.create_items(ITEMS, spec)
              end,
              params: ITEMS[:membership1].merge(links: {user_id: :user1, organization_id: :org2})
          },
          'duplicate role with different user' => {
              init: Proc.new do |ctx, spec|
                ctx.create_items(ITEMS, spec)
              end,
              params: ITEMS[:membership1].merge(links: {user_id: :user2, organization_id: :org1})
          },
          'duplicate role with same user and organization' => {
              init: Proc.new do |ctx, spec|
                ctx.create_items(ITEMS, spec)
              end,
              params: ITEMS[:membership1].merge(links: {user_id: :user1, organization_id: :org1}),
              failure: true,
              errors: {role: ['must be unique within its scope']}
          },
          'empty role' => {
              init: Proc.new do |ctx, spec|
                ctx.create_items(ITEMS, spec)
              end,
              params: ITEMS[:membership1].merge(data: {role: ''}),
              failure: true,
              errors: {name: ['must be filled', 'must be unique within its scope']}
          }
      },
      retrieve: {
          'get item' => {
              init: Proc.new do |ctx, spec|
                spec[:org1] = Teneo::DataModel::Organization::Operation::Create.(ITEMS[:org1])[model_param]
                spec[:check_params] = spec[:check_params].merge(organization_id: spec[:org1].id)
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:membership1].merge(organization_id: spec[:org1].id)))[model_param].id
              end,
              check_params: ITEMS[:membership1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with protocol and options' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx, spec)
                spec[:id] = spec[:membership1].id
              end,
              params: {protocol: 'gdrive', options: {'credentials_file' => 'credentials.json', 'path' => '/data'}},
              check_params: ITEMS[:membership1].merge(protocol: 'gdrive', options: {'credentials_file' => 'credentials.json', 'path' => '/data'}),
          },
          'name change' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx, spec)
                spec[:id] = spec[:membership1].id
              end,
              params: {name: 'cloud'},
              check_params: ITEMS[:membership1].merge(name: 'cloud'),
          },
          'duplicate name OK' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx, spec)
                spec[:id] = spec[:membership3].id
              end,
              params: {name: ITEMS[:membership2][:name]},
              check_params: ITEMS[:membership3].merge(name: ITEMS[:membership2][:name]),
          },
          'duplicate name not OK' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx, spec)
                spec[:id] = spec[:membership1].id
              end,
              params: {name: ITEMS[:membership2][:name]},
              failure: true,
              errors: {name: ['must be unique within its scope']},
          },
          'empty protocol' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx, spec)
                spec[:id] = spec[:membership1].id
              end,
              params: {protocol: ''},
              failure: true,
              errors: {protocol: ['must be filled']}
          },
          'empty options' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx, spec)
                spec[:id] = spec[:membership1].id
              end,
              params: {options: ''},
              failure: true,
              errors: {options: ['must be a hash']}
          },
          'remove protocol' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx, spec)
                spec[:id] = spec[:membership1].id
              end,
              params: {protocol: nil},
              failure: true,
              errors: {protocol: ['must be filled']}
          },
          'remove options' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx, spec)
                spec[:id] = spec[:membership1].id
              end,
              params: {options: nil},
              check_params: ITEMS[:membership1].merge(options: nil),
          }
      },
      delete: {
          'existing item' => {
              init: Proc.new do |ctx, spec|
                Storage::INIT.call(ctx, spec)
                spec[:id] = spec[:membership1].id
              end,
              check_params: ITEMS[:membership1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
