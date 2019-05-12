# frozen_string_literal: true
require_relative 'data_model_data'

module RetentionPolicyData

  MODEL = Teneo::DataModel::RetentionPolicy

  ITEMS = DataModelData::ITEMS.for(MODEL)

  # noinspection RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'PERMANENT'}},
              check_params: ITEMS.vslice(:ret_policy1)
          },
          'by ext_id' => {
              options: {filter: {ext_id: 'RP_NONE'}},
              check_params: ITEMS.vslice(:ret_policy1, :ret_policy3)
          },
          'by name and ext_id' => {
              options: {filter: {name: 'KEEP_FOREVER', ext_id: 'RP_NONE'}},
              check_params: ITEMS.vslice(:ret_policy3)
          },
          'by name and ext_id without match' => {
              options: {filter: {name: 'KEEP_FOREVER', ext_id: 'RP_10Y'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:ret_policy1],
              check_params: ITEMS[:ret_policy1][:data].merge(description: nil)
          },
          'full item' => {
              params: ITEMS[:ret_policy2]
          },
          'name missing' => {
              params: ITEMS[:ret_policy1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:ret_policy1])},
              params: ITEMS[:ret_policy1],
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              params: ITEMS[:ret_policy2].deep_merge(data: {description: ''}),
              failure: true,
              errors: {description: ['size cannot be less than 1']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:ret_policy1].id},
              check_params: ITEMS[:ret_policy1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              id: -> (ctx, spec) {spec[:ret_policy1].id},
              params: ITEMS[:ret_policy1].deep_merge(data: {description: 'Permanent storage'}),
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:ret_policy1].id},
              params: {name: 'PERM_STORAGE'},
              check_params: ITEMS[:ret_policy1],
          },
          'only description' => {
              id: -> (ctx, spec) {spec[:ret_policy1].id},
              params: {description: 'Permanent storage'},
              check_params: ITEMS[:ret_policy1][:data].merge(description: 'Permanent storage'),
          },
          'remove description' => {
              id: -> (ctx, spec) {spec[:ret_policy2].id},
              params: {description: nil},
              check_params: ITEMS[:ret_policy2][:data].merge(description: nil),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:ret_policy2].id},
              params: {name: ITEMS.dig(:ret_policy1, :data, :name)},
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:ret_policy2].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['size cannot be less than 1']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:ret_policy1].id},
              check_params: ITEMS[:ret_policy1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
