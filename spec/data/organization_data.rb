# frozen_string_literal: true

module Organization

  # noinspection RubyStringKeysInHashInspection
  ITEMS = {
      org1: {
          class: Teneo::DataModel::Organization,
          data: {name: 'Organization 1', inst_code: 'INST1'}
      },
      org2: {
          class: Teneo::DataModel::Organization,
          data: {name: 'Organization 2', inst_code: 'INST2', ingest_dir: '/org2', description: 'organization 2'}
      },
      org3: {
          class: Teneo::DataModel::Organization,
          data: {name: 'Organization 3', inst_code: 'INST2', ingest_dir: '/org3'}
      },
      org4: {
          class: Teneo::DataModel::Organization,
          data: {name: 'Organization 4', inst_code: 'INST1', description: 'organization 4'}
      }
  }

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'Organization 1'}},
              check_params: [ITEMS[:org1]]
          },
          'by inst_code' => {
              options: {filter: {inst_code: 'INST2'}},
              check_params: [ITEMS[:org2], ITEMS[:org3]]
          },
          'by ingest_dir' => {
              options: {filter: {ingest_dir: '/org3'}},
              check_params: [ITEMS[:org3]]
          },
          'by description' => {
              options: {filter: {description: 'organization 4'}},
              check_params: [ITEMS[:org4]]
          },
          'by inst_code and ingest_dir with match' => {
              options: {filter: {inst_code: 'INST2', ingest_dir: '/org3'}},
              check_params: [ITEMS[:org3]]
          },
          'by inst_code and ingest_dir without match' => {
              options: {filter: {inst_code: 'INST2', ingest_dir: '/org1'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:org1],
              check_params: ITEMS[:org1][:data].merge(ingest_dir: nil, description: nil)
          },
          'full item' => {
              params: ITEMS[:org2]
          },
          'name missing' => {
              params: ITEMS[:org1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:org1])},
              params: ITEMS[:org2].deep_merge(data: {name: ITEMS.dig(:org1, :data, :name)}),
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty name' => {
              params: ITEMS[:org2].deep_merge(data: {name: ''}),
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:org1].id},
              check_params: ITEMS[:org1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with ingest_dir and description' => {
              id: -> (ctx, spec) {spec[:org1].id},
              params: ITEMS[:org1].deep_merge(data: {ingest_dir: '/org1', description: 'organization 1'}),
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:org1].id},
              params: {name: 'Organization 99'},
              check_params: ITEMS[:org1],
          },
          'only inst_code change' => {
              id: -> (ctx, spec) {spec[:org1].id},
              params: {inst_code: 'INST99'},
              check_params: ITEMS[:org1][:data].merge(inst_code: 'INST99'),
          },
          'only ingest_dir and description' => {
              id: -> (ctx, spec) {spec[:org1].id},
              params: {ingest_dir: '/org1', description: 'organization 1'},
              check_params: ITEMS[:org1][:data].merge(ingest_dir: '/org1', description: 'organization 1'),
          },
          'remove ingest_dir and description' => {
              id: -> (ctx, spec) {spec[:org2].id},
              params: {ingest_dir: nil, description: nil},
              check_params: ITEMS[:org2][:data].merge(ingest_dir: nil, description: nil),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:org2].id},
              params: {name: ITEMS[:org1][:data][:name]},
              failure: true,
              errors: {name: ['must be unique']},
          },
          'empty ingest_dir' => {
              id: -> (ctx, spec) {spec[:org2].id},
              params: {ingest_dir: ''},
              failure: true,
              errors: {ingest_dir: ['must be filled']}
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:org2].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:org1].id},
              check_params: ITEMS[:org1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
