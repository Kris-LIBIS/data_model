# frozen_string_literal: true

module Organization

  # noinspection RubyStringKeysInHashInspection
  ITEMS = {
      org1: {name: 'Organization 1', inst_code: 'INST1'},
      org2: {name: 'Organization 2', inst_code: 'INST2', ingest_dir: '/org2', description: 'organization 2'},
      org3: {name: 'Organization 3', inst_code: 'INST2', ingest_dir: '/org3'},
      org4: {name: 'Organization 4', inst_code: 'INST1', description: 'organization 4'},
  }

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: ITEMS[:org1][:name]}},
              check_params: [ITEMS[:org1]]
          },
          'by inst_code' => {
              options: {filter: {inst_code: ITEMS[:org2][:inst_code]}},
              check_params: [ITEMS[:org2],ITEMS[:org3]]
          },
          'by ingest_dir' => {
              options: {filter: {ingest_dir: ITEMS[:org3][:ingest_dir]}},
              check_params: [ITEMS[:org3]]
          },
          'by description' => {
              options: {filter: {description: ITEMS[:org4][:description]}},
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
              check_params: ITEMS[:org1].merge(ingest_dir: nil, description: nil)
          },
          'full item' => {
              params: ITEMS[:org2]
          },
          'name missing' => {
              params: ITEMS[:org1].reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: Proc.new do |ctx, _spec|
                ctx.subject.(*build_params(ITEMS[:org1]))
              end,
              params: ITEMS[:org2].merge(name: ITEMS[:org1][:name]),
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty name' => {
              params: ITEMS[:org2].merge(name: ''),
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          }
      },
      retrieve: {
          'get item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org1]))[model_param].id
              end,
              check_params: ITEMS[:org1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with ingest_dir and description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org1]))[model_param].id
              end,
              params: ITEMS[:org1].merge(ingest_dir: '/org1', description: 'organization 1'),
          },
          'no name change' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org1]))[model_param].id
              end,
              params: {name: 'Organization 99'},
              check_params: ITEMS[:org1],
          },
          'only inst_code change' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org1]))[model_param].id
              end,
              params: {inst_code: 'INST99'},
              check_params: ITEMS[:org1].merge(inst_code: 'INST99'),
          },
          'only ingest_dir and description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org1]))[model_param].id
              end,
              params: {ingest_dir: '/org1', description: 'organization 1'},
              check_params: ITEMS[:org1].merge(ingest_dir: '/org1', description: 'organization 1'),
          },
          'remove ingest_dir and description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org2]))[model_param].id
              end,
              params: {ingest_dir: nil, description: nil},
              check_params: ITEMS[:org2].merge(ingest_dir: nil, description: nil),
          },
          'duplicate name' => {
              init: Proc.new do |ctx, spec|
                ctx.create_class.(*build_params(ITEMS[:org1]))[model_param]
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org2]))[model_param].id
              end,
              params: {name: ITEMS[:org1][:name]},
              failure: true,
              errors: {name: ['must be unique']},
          },
          'empty ingest_dir' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org2]))[model_param].id
              end,
              params: {ingest_dir: ''},
              failure: true,
              errors: {ingest_dir: ['must be filled']}
          },
          'empty description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org2]))[model_param].id
              end,
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:org1]))[model_param].id
              end,
              check_params: ITEMS[:org1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
