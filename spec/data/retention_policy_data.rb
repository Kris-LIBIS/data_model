# frozen_string_literal: true

module RetentionPolicy

  ITEMS = {
      permanent: {name: 'PERMANENT', ext_id: 'RP_NONE'},
      keep10y: {name: '10_YEARS', ext_id: 'RP_10Y', description: 'Keep for at least 10 years'},
      keep4ever: {name: 'KEEP_FOREVER', ext_id: 'RP_NONE'},
  }

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: ITEMS[:permanent][:name]}},
              check_params: [ITEMS[:permanent]]
          },
          'by ext_id' => {
              options: {filter: {ext_id: ITEMS[:permanent][:ext_id]}},
              check_params: [ITEMS[:permanent], ITEMS[:keep4ever]]
          },
          'by name and ext_id' => {
              options: {filter: {ext_id: ITEMS[:permanent][:ext_id], name: ITEMS[:keep4ever][:name]}},
              check_params: [ITEMS[:keep4ever]]
          },
          'by name and ext_id without match' => {
              options: {filter: {name: ITEMS[:permanent][:name], ext_id: ITEMS[:keep10y][:ext_id]}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:permanent],
              check_params: ITEMS[:permanent].merge(description: nil)
          },
          'full item' => {
              params: ITEMS[:keep10y]
          },
          'name missing' => {
              params: ITEMS[:permanent].reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: Proc.new do |ctx, spec|
                ctx.subject.(*build_params(spec[:params]))
              end,
              params: ITEMS[:permanent],
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              params: ITEMS[:keep10y].merge(description: ''),
              failure: true,
              errors: {description: ['size cannot be less than 1']}
          }
      },
      retrieve: {
          'get item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:permanent]))[model_param].id
              end,
              check_params: ITEMS[:permanent]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:permanent]))[model_param].id
              end,
              params: ITEMS[:permanent].merge(description: 'Permanent storage'),
          },
          'no name change' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:permanent]))[model_param].id
              end,
              params: {name: 'PERM_STORAGE'},
              check_params: ITEMS[:permanent],
          },
          'only description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:permanent]))[model_param].id
              end,
              params: {description: 'Permanent storage'},
              check_params: ITEMS[:permanent].merge(description: 'Permanent storage'),
          },
          'remove description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:keep10y]))[model_param].id
              end,
              params: {description: nil},
              check_params: ITEMS[:keep10y].merge(description: nil),
          },
          'duplicate name' => {
              init: Proc.new do |ctx, spec|
                ctx.create_class.(*build_params(ITEMS[:permanent]))[model_param]
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:keep10y]))[model_param].id
              end,
              params: {name: ITEMS[:permanent][:name]},
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:keep10y]))[model_param].id
              end,
              params: {description: ''},
              failure: true,
              errors: {description: ['size cannot be less than 1']}
          }
      },
      delete: {
          'existing item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:permanent]))[model_param].id
              end,
              check_params: ITEMS[:permanent]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
