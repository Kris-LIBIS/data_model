# frozen_string_literal: true

module MaterialFlow

  ITEMS = {
      ingester: {name: 'Ingester', ext_id: '1000', inst_code: 'INST1'},
      collections: {name: 'Collections', ext_id: '2000', inst_code: 'INST1', description: 'Create Collections'},
      other: {name: 'Ingester', ext_id: '3000', inst_code: 'INST2', description: 'Other ingester workflow'},
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
              check_params: ITEMS[:ingester].merge(description: nil)
          },
          'full item' => {
              params: ITEMS[:collections]
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
          'duplicate name with same inst_code' => {
              init: Proc.new do |ctx, spec|
                ctx.subject.(*build_params(spec[:params]))
              end,
              params: ITEMS[:ingester],
              failure: true,
              errors: {unique_combo: ["must be a unique combination"]}
          },
          'duplicate name but other inst_code' => {
              init: Proc.new do |ctx, spec|
                ctx.subject.(*build_params(ITEMS[:ingester]))
              end,
              params: ITEMS[:ingester].merge(inst_code: 'OTHER_INST')
          },
          'empty description' => {
              params: ITEMS[:collections].merge(description: ''),
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
              params: ITEMS[:ingester].merge(description: 'Ingester workflow'),
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
              params: {description: 'Ingester workflow'},
              check_params: ITEMS[:ingester].merge(description: 'Ingester workflow'),
          },
          'remove description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:collections]))[model_param].id
              end,
              params: {description: nil},
              check_params: ITEMS[:collections].merge(description: nil),
          },
          'empty description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:collections]))[model_param].id
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
