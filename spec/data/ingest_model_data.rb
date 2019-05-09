# frozen_string_literal: true

module IngestModel

  # noinspection RubyStringKeysInHashInspection
  ITEMS = {
      rp1: {
          class: Teneo::DataModel::RetentionPolicy,
          data: {name: 'PERMANENT', ext_id: 'RP_NONE'}
      },
      ar1: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'PUBLIC', ext_id: 'AR_PUBLIC'}
      },
      ing_model1: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model 1'},
          links: {retention_policy_id: :rp1, access_right_id: :ar1}
      },
      ing_model2: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model 2', description: 'ingest model 2', entity_type: 'entity type 1',
                 user_a: 'a', user_b: 'b', user_c: 'c', identifier: '123', status: 'stored'},
          links: {retention_policy_id: :rp1, access_right_id: :ar1}
      },
      ing_model3: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model 3'},
          links: {retention_policy_id: :rp1, access_right_id: :ar1}
      },
  }

  # noinspection RubyStringKeysInHashInspection,RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: [ITEMS[:ing_model1], ITEMS[:ing_model2], ITEMS[:ing_model3]]
          },
          'by name' => {
              options: {filter: {name: 'model 1'}},
              check_params: [ITEMS[:ing_model1]]
          },
          'by name without match' => {
              options: {filter: {name: 'model xxx'}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:ing_model1]
          },
          'complete item' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:ing_model2]
          },
          'name missing' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:ing_model1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1, :ing_model1)},
              params: ITEMS[:ing_model2].deep_merge(data: {name: 'model 1'}),
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty name' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:ing_model1].deep_merge(data: {name: ''}),
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:ing_model1].id},
              check_params: ITEMS[:ing_model1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'name change' => {
              id: -> (ctx, spec) {spec[:ing_model1].id},
              params: {name: 'model xxx'},
              check_params: ITEMS[:ing_model1][:data].merge(name: 'model xxx'),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:ing_model1].id},
              params: {name: 'model 2'},
              failure: true,
              errors: {name: ['must be unique']},
          },
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:ing_model1].id},
              check_params: ITEMS[:ing_model1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
