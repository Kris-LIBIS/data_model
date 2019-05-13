# frozen_string_literal: true
require_relative 'data_model_data'

module WorkflowData

  MODEL = Teneo::DataModel::Workflow

  ITEMS = DataModelData::ITEMS.for(MODEL)

  # noinspection RubyUnusedLocalVariable,RubyStringKeysInHashInspection
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.only(MODEL).values
          },
          'by name' => {
              options: {filter: {name: 'converter 1'}},
              check_params: ITEMS.vslice(:converter1)
          },
          'by name without match' => {
              options: {filter: {name: 'converter x'}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              params: ITEMS[:converter1],
              check_params: ITEMS[:converter1]
          },
          'name missing' => {
              params: ITEMS[:converter1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled']}
          },
          'empty name' => {
              params: ITEMS[:converter1].deep_merge(data: {name: ''}),
              failure: true,
              errors: {name: ['must be filled']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:converter1].id},
              check_params: ITEMS[:converter1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              id: -> (ctx, spec) {spec[:converter1].id},
              params: {description: 'some converter'},
              check_params: ITEMS[:converter1][:data].merge({description: 'some converter'}),
          },
          'name change' => {
              id: -> (ctx, spec) {spec[:converter1].id},
              params: {name: 'converter x'},
              check_params: ITEMS[:converter1][:data].merge(name: 'converter x'),
          },
          'with class and parameters' => {
              id: -> (ctx, spec) {spec[:converter3].id},
              params: {class_name: 'ConverterClass', parameters: {param1: {type: 'string', descr: 'some parameter', default: 'abc'}}},
              check_params: ITEMS[:converter3][:data].merge(class_name: 'ConverterClass', parameters: {param1: {type: 'string', descr: 'some parameter', default: 'abc'}}),
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:converter2].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
      },
          'empty class_name and parameters' => {
              id: -> (ctx, spec) {spec[:converter3].id},
              params: {class_name: '', parameters: ''},
              failure: true,
              errors: {class_name: ['must be filled'], parameters: ['must be filled']}
      },
          'remove description' => {
              id: -> (ctx, spec) {spec[:converter2].id},
              params: {description: nil},
              check_params: ITEMS[:converter2][:data].merge(description: nil),
      },
          'remove class_name and parameters' => {
              id: -> (ctx, spec) {spec[:converter3].id},
              params: {class_name: nil, parameters: nil},
              check_params: ITEMS[:converter3][:data].merge(class_name: nil, parameters: nil),
          }
  },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:converter1].id},
              check_params: ITEMS[:converter1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
