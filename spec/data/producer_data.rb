# frozen_string_literal: true
require_relative 'data_model_data'

module ProducerData

  MODEL = Teneo::DataModel::Producer
  
  ITEMS = DataModelData::ITEMS.for(MODEL)

  # noinspection RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'Ingester'}},
              check_params: ITEMS.vslice(:producer1, :producer3)
          },
          'by ext_id' => {
              options: {filter: {ext_id: '1000'}},
              check_params: ITEMS.vslice(:producer1)
          },
          'by name and inst_code' => {
              options: {filter: {name: 'Ingester', inst_code: 'INST2'}},
              check_params: ITEMS.vslice(:producer3)
          },
          'by name and inst_code without match' => {
              options: {filter: {name: 'Producer', inst_code: 'INST2'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:producer1],
              check_params: ITEMS[:producer1][:data].merge(description: nil)
          },
          'full item' => {
              params: ITEMS[:producer2]
          },
          'name missing' => {
              params: ITEMS[:producer1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'values in scope of inst_code, name must be unique']}
          },
          'ext_id missing' => {
              params: ITEMS[:producer1].deep_reject {|k| k == :ext_id},
              failure: true,
              errors: {ext_id: ['must be filled']}
          },
          'inst_code missing' => {
              params: ITEMS[:producer1].deep_reject {|k| k == :inst_code},
              failure: true,
              errors: {inst_code: ['must be filled']}
          },
          'agent missing' => {
              params: ITEMS[:producer1].deep_reject {|k| k == :agent},
              failure: true,
              errors: {agent: ['must be filled']}
          },
          'password missing' => {
              params: ITEMS[:producer1].deep_reject {|k| k == :password},
              failure: true,
              errors: {password: ['must be filled']}
          },
          'duplicate name with same inst_code' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:producer1])},
              params: ITEMS[:producer1],
              failure: true,
              errors: {name: ["values in scope of inst_code, name must be unique"]}
          },
          'duplicate name but other inst_code' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:producer1])},
              params: ITEMS[:producer1].deep_merge(data: {inst_code: 'OTHER_INST'})
          },
          'empty description' => {
              params: ITEMS[:producer2].deep_merge(data:{description: ''}),
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:producer1].id},
              check_params: ITEMS[:producer1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              id: -> (ctx, spec) {spec[:producer1].id},
              params: ITEMS[:producer1].deep_merge(data:{description: 'Ingester producer'}),
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:producer1].id},
              params: {name: 'Something else'},
              check_params: ITEMS[:producer1],
          },
          'only description' => {
              id: -> (ctx, spec) {spec[:producer1].id},
              params: {description: 'Ingester producer'},
              check_params: ITEMS[:producer1][:data].merge(description: 'Ingester producer'),
          },
          'remove description' => {
              id: -> (ctx, spec) {spec[:producer2].id},
              params: {description: nil},
              check_params: ITEMS[:producer2][:data].merge(description: nil),
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:producer2].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:producer1].id},
              check_params: ITEMS[:producer1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
