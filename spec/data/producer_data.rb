# frozen_string_literal: true

module Producer

  ITEMS = {
      ingester: {
          class: Teneo::DataModel::Producer,
          data: {name: 'Ingester', ext_id: '1000', inst_code: 'INST1', agent: 'ingester', password: 'abc123'}
      },
      producer: {
          class: Teneo::DataModel::Producer,
          data: {name: 'Producer', ext_id: '2000', inst_code: 'INST1', agent: 'producer', password: 'abc123', description: 'Regular producer'}
      },
      other: {
          class: Teneo::DataModel::Producer,
          data: {name: 'Ingester', ext_id: '3000', inst_code: 'INST2', agent: 'producer', password: 'abc123'}
      }
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
              options: {filter: {name: 'Producer', inst_code: 'INST2'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:ingester],
              check_params: ITEMS[:ingester][:data].merge(description: nil)
          },
          'full item' => {
              params: ITEMS[:producer]
          },
          'name missing' => {
              params: ITEMS[:ingester].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique within its scope']}
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
          'agent missing' => {
              params: ITEMS[:ingester].deep_reject {|k| k == :agent},
              failure: true,
              errors: {agent: ['must be filled']}
          },
          'password missing' => {
              params: ITEMS[:ingester].deep_reject {|k| k == :password},
              failure: true,
              errors: {password: ['must be filled']}
          },
          'duplicate name with same inst_code' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:ingester])},
              params: ITEMS[:ingester],
              failure: true,
              errors: {name: ["must be unique within its scope"]}
          },
          'duplicate name but other inst_code' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:ingester])},
              params: ITEMS[:ingester].deep_merge(data: {inst_code: 'OTHER_INST'})
          },
          'empty description' => {
              params: ITEMS[:producer].deep_merge(data:{description: ''}),
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
              params: ITEMS[:ingester].merge(description: 'Ingester producer'),
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:ingester].id},
              params: {name: 'Something else'},
              check_params: ITEMS[:ingester],
          },
          'only description' => {
              id: -> (ctx, spec) {spec[:ingester].id},
              params: {description: 'Ingester producer'},
              check_params: ITEMS[:ingester].merge(description: 'Ingester producer'),
          },
          'remove description' => {
              id: -> (ctx, spec) {spec[:producer].id},
              params: {description: nil},
              check_params: ITEMS[:producer].merge(description: nil),
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:producer].id},
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
