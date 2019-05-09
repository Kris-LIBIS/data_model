# frozen_string_literal: true

module RetentionPolicy

  ITEMS = {
      permanent: {
          class: Teneo::DataModel::RetentionPolicy,
          data: {name: 'PERMANENT', ext_id: 'RP_NONE'}
      },
      keep10y: {
          class: Teneo::DataModel::RetentionPolicy,
          data: {name: '10_YEARS', ext_id: 'RP_10Y', description: 'Keep for at least 10 years'}
      },
      keep4ever: {
          class: Teneo::DataModel::RetentionPolicy,
          data: {name: 'KEEP_FOREVER', ext_id: 'RP_NONE'}
      }
  }

  # noinspection RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'PERMANENT'}},
              check_params: [ITEMS[:permanent]]
          },
          'by ext_id' => {
              options: {filter: {ext_id: 'RP_NONE'}},
              check_params: [ITEMS[:permanent], ITEMS[:keep4ever]]
          },
          'by name and ext_id' => {
              options: {filter: {name: 'KEEP_FOREVER', ext_id: 'RP_NONE'}},
              check_params: [ITEMS[:keep4ever]]
          },
          'by name and ext_id without match' => {
              options: {filter: {name: 'KEEP_FOREVER', ext_id: 'RP_10Y'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:permanent],
              check_params: ITEMS[:permanent][:data].merge(description: nil)
          },
          'full item' => {
              params: ITEMS[:keep10y]
          },
          'name missing' => {
              params: ITEMS[:permanent].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:permanent])},
              params: ITEMS[:permanent],
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              params: ITEMS[:keep10y].deep_merge(data: {description: ''}),
              failure: true,
              errors: {description: ['size cannot be less than 1']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:permanent].id},
              check_params: ITEMS[:permanent]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              id: -> (ctx, spec) {spec[:permanent].id},
              params: ITEMS[:permanent].deep_merge(data: {description: 'Permanent storage'}),
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:permanent].id},
              params: {name: 'PERM_STORAGE'},
              check_params: ITEMS[:permanent],
          },
          'only description' => {
              id: -> (ctx, spec) {spec[:permanent].id},
              params: {description: 'Permanent storage'},
              check_params: ITEMS[:permanent][:data].merge(description: 'Permanent storage'),
          },
          'remove description' => {
              id: -> (ctx, spec) {spec[:keep10y].id},
              params: {description: nil},
              check_params: ITEMS[:keep10y][:data].merge(description: nil),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:keep10y].id},
              params: {name: ITEMS.dig(:permanent, :data, :name)},
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:keep10y].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['size cannot be less than 1']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:permanent].id},
              check_params: ITEMS[:permanent]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
