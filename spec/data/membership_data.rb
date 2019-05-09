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
      membership5: {
          class: Teneo::DataModel::Membership,
          data: {role: 'admin'},
          links: {user_id: :user1, organization_id: :org1}
      }
  }

  # noinspection RubyStringKeysInHashInspection
  TESTS = {
      index: {
          'get all' => {
              check_params: [ITEMS[:membership1], ITEMS[:membership2], ITEMS[:membership3], ITEMS[:membership4], ITEMS[:membership5]]
          },
          'by role' => {
              options: {filter: {role: 'admin'}},
              check_params: [ITEMS[:membership3], ITEMS[:membership4], ITEMS[:membership5]]
          },
          'by organization_id' => {
              options: -> (ctx, spec) {{filter: {organization_id: spec[:org1].id}}},
              check_params: [ITEMS[:membership1], ITEMS[:membership3], ITEMS[:membership5]]
          },
          'by user_id' => {
              options: -> (ctx, spec) {{filter: {user_id: spec[:user1].id}}},
              check_params: [ITEMS[:membership1], ITEMS[:membership2], ITEMS[:membership5]]
          },
          'by user_id and role with match' => {
              options: -> (ctx, spec) {{filter: {user_id: spec[:user2].id, role: 'admin'}}},
              check_params: [ITEMS[:membership3], ITEMS[:membership4]]
          },
          'by user_id and role without match' => {
              options: -> (ctx, spec) {{filter: {user_id: spec[:user2].id, role: 'uploader'}}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              init: -> (ctx, spec) {spec[:org1] = ctx.create_item(spec, ITEMS[:org1])
                spec[:user1] = ctx.create_item(spec, ITEMS[:user1])
              },
              params: ITEMS[:membership1],
              check_params: ITEMS[:membership1]
          },
          'role missing' => {
              init: -> (ctx, spec) {spec[:org1] = ctx.create_item(spec, ITEMS[:org1])
                spec[:user1] = ctx.create_item(spec, ITEMS[:user1])
              },
              params: ITEMS[:membership1].deep_reject {|k| k == :role},
              failure: true,
              errors: {role: ['must be filled', 'must be one of: uploader, ingester, admin', 'values in scope of organization_id, user_id, role must be unique']}
          },
          'duplicate role with different organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec)},
              params: ITEMS[:membership1].deep_merge(links: {user_id: :user1, organization_id: :org2})
          },
          'duplicate role with different user' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec)},
              params: ITEMS[:membership1].deep_merge(links: {user_id: :user2, organization_id: :org1})
          },
          'duplicate role with same user and organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec)},
              params: ITEMS[:membership1].deep_merge(links: {user_id: :user1, organization_id: :org1}),
              failure: true,
              errors: {role: ['values in scope of organization_id, user_id, role must be unique']}
          },
          'empty role' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec)},
              params: ITEMS[:membership1].deep_merge(data: {role: ''}),
              failure: true,
              errors: {role: ['must be filled', 'must be one of: uploader, ingester, admin', 'values in scope of organization_id, user_id, role must be unique']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:membership1].id},
              check_params: ITEMS[:membership1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'role change' => {
              id: -> (ctx, spec) {spec[:membership1].id},
              params: {role: 'uploader'},
              check_params: ITEMS[:membership1].deep_merge(data: {role: 'uploader'}),
          },
          'role change duplicate' => {
              id: -> (ctx, spec) {spec[:membership1].id},
              params: {role: 'admin'},
              failure: true,
              errors: {role: ['values in scope of organization_id, user_id, role must be unique']},
          },
          'empty role' => {
              id: -> (ctx, spec) {spec[:membership1].id},
              params: {role: ''},
              failure: true,
              errors: {role: ['must be filled', 'must be one of: uploader, ingester, admin', 'values in scope of organization_id, user_id, role must be unique']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:membership1].id},
              check_params: ITEMS[:membership1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
