# frozen_string_literal: true

module AccessRight

  ITEMS = {
      public: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'PUBLIC', ext_id: 'AR_PUBLIC'}
      },
      private: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'PRIVATE', ext_id: 'AR_PRIVATE', description: 'Private access'}
      },
      open: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'OPEN', ext_id: 'AR_PUBLIC'}
      },
  }

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'PUBLIC'}},
              check_params: [ITEMS[:public]]
          },
          'by ext_id' => {
              options: {filter: {ext_id: 'AR_PUBLIC'}},
              check_params: [ITEMS[:public], ITEMS[:open]]
          },
          'by name and ext_id' => {
              options: {filter: {name: 'OPEN', ext_id: 'AR_PUBLIC'}},
              check_params: [ITEMS[:open]]
          },
          'by name and ext_id without match' => {
              options: {filter: {name: 'PUBLIC', ext_id: 'AR_PRIVATE'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:public],
              check_params: ITEMS[:public].deep_merge(data: {description: nil})
          },
          'full item' => {
              params: ITEMS[:private]
          },
          'name missing' => {
              params: ITEMS[:public].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_item(spec, spec[:params])},
              params: ITEMS[:public],
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              params: ITEMS[:private].deep_merge(data: {description: ''}),
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:public].id},
              check_params: ITEMS[:public]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'change description' => {
              id: -> (ctx, spec) {spec[:public].id},
              params: {description: 'Public access'},
              check_params: ITEMS[:public].deep_merge(data: {description: 'Public access'})
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:public].id},
              params: {name: 'SEMI-PUBLIC'},
              check_params: ITEMS[:public]
          },
          'remove description' => {
              id: -> (ctx, spec) {spec[:private].id},
              params: {description: nil},
              check_params: ITEMS[:private].deep_merge(data: {description: nil}),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:private].id},
              params: {name: ITEMS[:public][:data][:name]},
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:private].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:public].id},
              check_params: ITEMS[:public]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
