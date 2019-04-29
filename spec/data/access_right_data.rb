# frozen_string_literal: true

module AccessRight

  ITEMS = {
      public: {name: 'PUBLIC', ext_id: 'AR_PUBLIC'},
      private: {name: 'PRIVATE', ext_id: 'AR_PRIVATE', description: 'Private access'},
      open: {name: 'OPEN', ext_id: 'AR_PUBLIC'},
  }

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: ITEMS[:public][:name]}},
              check_params: [ITEMS[:public]]
          },
          'by ext_id' => {
              options: {filter: {ext_id: ITEMS[:public][:ext_id]}},
              check_params: [ITEMS[:public], ITEMS[:open]]
          },
          'by name and ext_id' => {
              options: {filter: {ext_id: ITEMS[:public][:ext_id], name: ITEMS[:open][:name]}},
              check_params: [ITEMS[:open]]
          },
          'by name and ext_id without match' => {
              options: {filter: {name: ITEMS[:public][:name], ext_id: ITEMS[:private][:ext_id]}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:public],
              check_params: ITEMS[:public].merge(description: nil)
          },
          'full item' => {
              params: ITEMS[:private]
          },
          'name missing' => {
              params: ITEMS[:public].reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: Proc.new do |ctx, spec|
                ctx.subject.(*build_params(spec[:params]))
              end,
              params: ITEMS[:public],
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              params: ITEMS[:private].merge(description: ''),
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      retrieve: {
          'get item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:public]))[model_param].id
              end,
              check_params: ITEMS[:public]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:public]))[model_param].id
              end,
              params: ITEMS[:public].merge(description: 'Public access'),
          },
          'no name change' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:public]))[model_param].id
              end,
              params: {name: 'OPEN'},
              check_params: ITEMS[:public],
          },
          'only description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:public]))[model_param].id
              end,
              params: {description: 'Public access'},
              check_params: ITEMS[:public].merge(description: 'Public access'),
          },
          'remove description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:private]))[model_param].id
              end,
              params: {description: nil},
              check_params: ITEMS[:private].merge(description: nil),
          },
          'duplicate name' => {
              init: Proc.new do |ctx, spec|
                ctx.create_class.(*build_params(ITEMS[:public]))[model_param]
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:private]))[model_param].id
              end,
              params: {name: ITEMS[:public][:name]},
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:private]))[model_param].id
              end,
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:public]))[model_param].id
              end,
              check_params: ITEMS[:public]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
