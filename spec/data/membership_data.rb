# frozen_string_literal: true
require_relative 'data_model_data'

module MembershipData

  MODEL = Teneo::DataModel::Membership

  ITEMS = DataModelData::ITEMS.for(MODEL)

  # noinspection RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.only(MODEL).values
          },
          'by role' => {
              options: {filter: {role: 'admin'}},
              check_params: ITEMS.vslice(:membership3, :membership4, :membership5)
          },
          'by organization_id' => {
              options: -> (ctx, spec) {{filter: {organization_id: spec[:org1].id}}},
              check_params: ITEMS.vslice(:membership1, :membership3, :membership5)
          },
          'by user_id' => {
              options: -> (ctx, spec) {{filter: {user_id: spec[:user1].id}}},
              check_params: ITEMS.vslice(:membership1, :membership2, :membership5)
          },
          'by user_id and role with match' => {
              options: -> (ctx, spec) {{filter: {user_id: spec[:user2].id, role: 'admin'}}},
              check_params: ITEMS.vslice(:membership3, :membership4)
          },
          'by user_id and role without match' => {
              options: -> (ctx, spec) {{filter: {user_id: spec[:user2].id, role: 'uploader'}}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :membership1)},
              params: ITEMS[:membership1],
              check_params: ITEMS[:membership1]
          },
          'role missing' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :membership1)},
              params: ITEMS[:membership1].deep_reject {|k| k == :role},
              failure: true,
              errors: {role: ['must be filled', 'must be one of: uploader, ingester, admin', 'values in scope of organization_id, user_id, role must be unique']}
          },
          'duplicate role with different organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :membership1, :org2)},
              params: ITEMS[:membership1].deep_merge(links: {user_id: :user1, organization_id: :org2})
          },
          'duplicate role with different user' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :membership1, :user2)},
              params: ITEMS[:membership1].deep_merge(links: {user_id: :user2, organization_id: :org1})
          },
          'duplicate role with same user and organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :membership1)},
              params: ITEMS[:membership1],
              failure: true,
              errors: {role: ['values in scope of organization_id, user_id, role must be unique']}
          },
          'empty role' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :membership1)},
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
