# frozen_string_literal: true
require_relative 'data_model_data'

module MaterialFlowData

  MODEL = Teneo::DataModel::MaterialFlow

  ITEMS = DataModelData::ITEMS.for(MODEL)

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'Ingester'}},
              check_params: ITEMS.vslice(:material_flow1, :material_flow3, :material_flow4)
          },
          'by ext_id' => {
              options: {filter: {ext_id: '1000'}},
              check_params: ITEMS.vslice(:material_flow1)
          },
          'by name and inst_code' => {
              options: {filter: {name: 'Ingester', inst_code: 'INST2'}},
              check_params: ITEMS.vslice(:material_flow3)
          },
          'by name and inst_code without match' => {
              options: {filter: {name: 'Collections', inst_code: 'INST2'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:material_flow1],
              check_params: ITEMS[:material_flow1].deep_merge(data:{description: nil})
          },
          'full item' => {
              params: ITEMS[:material_flow2]
          },
          'name missing' => {
              params: ITEMS[:material_flow1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'values in scope of inst_code, name must be unique']}
          },
          'ext_id missing' => {
              params: ITEMS[:material_flow1].deep_reject {|k| k == :ext_id},
              failure: true,
              errors: {ext_id: ['must be filled']}
          },
          'inst_code missing' => {
              params: ITEMS[:material_flow1].deep_reject {|k| k == :inst_code},
              failure: true,
              errors: {inst_code: ['must be filled']}
          },
          'duplicate name with same inst_code' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:material_flow1])},
              params: ITEMS[:material_flow1],
              failure: true,
              errors: {name: ["values in scope of inst_code, name must be unique"]}
          },
          'duplicate name but other inst_code' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:material_flow1])},
              params: ITEMS[:material_flow1].deep_merge(data: {inst_code: 'OTHER_INST'})
          },
          'empty description' => {
              params: ITEMS[:material_flow2].deep_merge(data: {description: ''}),
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:material_flow1].id},
              check_params: ITEMS[:material_flow1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              id: -> (ctx, spec) {spec[:material_flow1].id},
              params: ITEMS[:material_flow1].deep_merge(data: {description: 'Ingester workflow'}),
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:material_flow1].id},
              params: {name: 'Something else'},
              check_params: ITEMS[:material_flow1],
          },
          'only description' => {
              id: -> (ctx, spec) {spec[:material_flow1].id},
              params: {description: 'Ingester workflow'},
              check_params: ITEMS[:material_flow1].deep_merge(data: {description: 'Ingester workflow'}),
          },
          'remove description' => {
              id: -> (ctx, spec) {spec[:material_flow2].id},
              params: {description: nil},
              check_params: ITEMS[:material_flow2].deep_merge(data: {description: nil}),
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:material_flow2].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:material_flow1].id},
              check_params: ITEMS[:material_flow1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
