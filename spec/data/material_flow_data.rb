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
              check_params: ITEMS[:ingester][:data].merge(description: nil)
          },
          'full item' => {
              params: ITEMS[:collections]
          },
          'name missing' => {
              params: ITEMS[:ingester][:data].reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique within its scope']}
          },
          'ext_id missing' => {
              params: ITEMS[:ingester][:data].reject {|k| k == :ext_id},
              failure: true,
              errors: {ext_id: ['must be filled']}
          },
          'inst_code missing' => {
              params: ITEMS[:ingester][:data].reject {|k| k == :inst_code},
              failure: true,
              errors: {inst_code: ['must be filled']}
          },
          'duplicate name with same inst_code' => {
              init: Proc.new do |ctx, spec|
                ctx.create_item(spec, ITEMS[:ingester])
              end,
              params: ITEMS[:ingester],
              failure: true,
              errors: {name: ["must be unique within its scope"]}
          },
          'duplicate name but other inst_code' => {
              init: Proc.new do |ctx, spec|
                ctx.create_item(spec, ITEMS[:ingester])
              end,
              params: ITEMS[:ingester][:data].merge(inst_code: 'OTHER_INST')
          },
          'empty description' => {
              params: ITEMS[:collections][:data].merge(description: ''),
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      retrieve: {
          'get item' => {
              id: Proc.new {|_ctx, spec| spec[:ingester].id},
              check_params: ITEMS[:ingester]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              id: Proc.new {|_ctx, spec| spec[:ingester].id},
              params: ITEMS[:ingester][:data].merge(description: 'Ingester workflow'),
          },
          'no name change' => {
              id: Proc.new {|_ctx, spec| spec[:ingester].id},
              params: {name: 'Something else'},
              check_params: ITEMS[:ingester],
          },
          'only description' => {
              id: Proc.new {|_ctx, spec| spec[:ingester].id},
              params: {description: 'Ingester workflow'},
              check_params: ITEMS[:ingester][:data].merge(description: 'Ingester workflow'),
          },
          'remove description' => {
              id: Proc.new {|_ctx, spec| spec[:collections].id},
              params: {description: nil},
              check_params: ITEMS[:collections][:data].merge(description: nil),
          },
          'empty description' => {
              id: Proc.new {|_ctx, spec| spec[:collections].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              id: Proc.new {|_ctx, spec| spec[:ingester].id},
              check_params: ITEMS[:ingester]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
