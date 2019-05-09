# frozen_string_literal: true

module MaterialFlow

  ITEMS = {
      ingester: {
          class: Teneo::DataModel::MaterialFlow,
          data: {name: 'Ingester', ext_id: '1000', inst_code: 'INST1'}
      },
      collections: {
          class: Teneo::DataModel::MaterialFlow,
          data: {name: 'Collections', ext_id: '2000', inst_code: 'INST1', description: 'Create Collections'}
      },
      other: {
          class: Teneo::DataModel::MaterialFlow,
          data: {name: 'Ingester', ext_id: '3000', inst_code: 'INST2', description: 'Other ingester workflow'}
      },
  }

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'Ingester'}},
              check_params: [ITEMS[:ingester], ITEMS[:other]]
          },
          'by ext_id' => {
              options: {filter: {ext_id: '1000'}},
              check_params: [ITEMS[:ingester]]
          },
          'by name and inst_code' => {
              options: {filter: {name: 'Ingester', inst_code: 'INST2'}},
              check_params: [ITEMS[:other]]
          },
          'by name and inst_code without match' => {
              options: {filter: {name: 'Collections', inst_code: 'INST2'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:ingester],
              check_params: ITEMS[:ingester].deep_merge(data:{description: nil})
          },
          'full item' => {
              params: ITEMS[:collections]
          },
          'name missing' => {
              params: ITEMS[:ingester].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'values in scope of inst_code, name must be unique']}
          },
          'ext_id missing' => {
              params: ITEMS[:ingester].deep_reject {|k| k == :ext_id},
              failure: true,
              errors: {ext_id: ['must be filled']}
          },
          'inst_code missing' => {
              params: ITEMS[:ingester].deep_reject {|k| k == :inst_code},
              failure: true,
              errors: {inst_code: ['must be filled']}
          },
          'duplicate name with same inst_code' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:ingester])},
              params: ITEMS[:ingester],
              failure: true,
              errors: {name: ["values in scope of inst_code, name must be unique"]}
          },
          'duplicate name but other inst_code' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:ingester])},
              params: ITEMS[:ingester].deep_merge(data: {inst_code: 'OTHER_INST'})
          },
          'empty description' => {
              params: ITEMS[:collections].deep_merge(data: {description: ''}),
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:ingester].id},
              check_params: ITEMS[:ingester]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              id: -> (ctx, spec) {spec[:ingester].id},
              params: ITEMS[:ingester].deep_merge(data: {description: 'Ingester workflow'}),
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:ingester].id},
              params: {name: 'Something else'},
              check_params: ITEMS[:ingester],
          },
          'only description' => {
              id: -> (ctx, spec) {spec[:ingester].id},
              params: {description: 'Ingester workflow'},
              check_params: ITEMS[:ingester].deep_merge(data: {description: 'Ingester workflow'}),
          },
          'remove description' => {
              id: -> (ctx, spec) {spec[:collections].id},
              params: {description: nil},
              check_params: ITEMS[:collections].deep_merge(data: {description: nil}),
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:collections].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:ingester].id},
              check_params: ITEMS[:ingester]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
