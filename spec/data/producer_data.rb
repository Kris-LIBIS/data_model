# frozen_string_literal: true

module Producer

  ITEMS = {
      ingester: {name: 'Ingester', ext_id: '1000', inst_code: 'INST1', agent: 'ingester', password: 'abc123'},
      producer: {name: 'Producer', ext_id: '2000', inst_code: 'INST1', agent: 'producer', password: 'abc123', description: 'Regular producer'},
      other: {name: 'Ingester', ext_id: '3000', inst_code: 'INST2', agent: 'producer', password: 'abc123'},
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
              check_params: ITEMS[:ingester].merge(description: nil)
          },
          'full item' => {
              params: ITEMS[:producer]
          },
          'name missing' => {
              params: ITEMS[:ingester].reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled']}
          },
          'ext_id missing' => {
              params: ITEMS[:ingester].reject {|k| k == :ext_id},
              failure: true,
              errors: {ext_id: ['must be filled']}
          },
          'inst_code missing' => {
              params: ITEMS[:ingester].reject {|k| k == :inst_code},
              failure: true,
              errors: {inst_code: ['must be filled']}
          },
          'agent missing' => {
              params: ITEMS[:ingester].reject {|k| k == :agent},
              failure: true,
              errors: {agent: ['must be filled']}
          },
          'password missing' => {
              params: ITEMS[:ingester].reject {|k| k == :password},
              failure: true,
              errors: {password: ['must be filled']}
          },
          'duplicate name with same inst_code' => {
              init: Proc.new do |ctx, spec|
                ctx.subject.(*build_params(spec[:params]))
              end,
              params: ITEMS[:ingester],
              failure: true,
              errors: {unique_combo: ["must be a unique combination"]}
          },
          'duplicate name but other inst_code' => {
              init: Proc.new do |ctx, _spec|
                ctx.subject.(*build_params(ITEMS[:ingester]))
              end,
              params: ITEMS[:ingester].merge(inst_code: 'OTHER_INST')
          },
          'empty description' => {
              params: ITEMS[:producer].merge(description: ''),
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      retrieve: {
          'get item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:ingester]))[model_param].id
              end,
              check_params: ITEMS[:ingester]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:ingester]))[model_param].id
              end,
              params: ITEMS[:ingester].merge(description: 'Ingester producer'),
          },
          'no name change' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:ingester]))[model_param].id
              end,
              params: {name: 'Something else'},
              check_params: ITEMS[:ingester],
          },
          'only description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:ingester]))[model_param].id
              end,
              params: {description: 'Ingester producer'},
              check_params: ITEMS[:ingester].merge(description: 'Ingester producer'),
          },
          'remove description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:producer]))[model_param].id
              end,
              params: {description: nil},
              check_params: ITEMS[:producer].merge(description: nil),
          },
          'empty description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:producer]))[model_param].id
              end,
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:ingester]))[model_param].id
              end,
              check_params: ITEMS[:ingester]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
