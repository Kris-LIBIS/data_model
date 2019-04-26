# frozen_string_literal: true

module RepresentationInfo

  ITEMS = {
      archive: {name: 'ARCHIVE', preservation_type: 'PRESERVATION_MASTER', usage_type: 'VIEW'},
      high: {name: 'VIEW_MAIN', preservation_type: 'DERIVATIVE_COPY', usage_type: 'VIEW', representation_code: 'HIGH'},
      low: {name: 'VIEW', preservation_type: 'DERIVATIVE_COPY', usage_type: 'VIEW', representation_code: 'LOW'},
      thumbnail: {name: 'THUMBNAIL', preservation_type: 'DERIVATIVE_COPY', usage_type: 'THUMBNAIL', representation_code: 'THUMBNAIL'},
  }

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'ARCHIVE'}},
              check_params: [ITEMS[:archive]]
          },
          'by preservation_type' => {
              options: {filter: {preservation_type: 'DERIVATIVE_COPY'}},
              check_params: [ITEMS[:high], ITEMS[:low], ITEMS[:thumbnail]]
          },
          'by usage_type' => {
              options: {filter: {usage_type: 'VIEW'}},
              check_params: [ITEMS[:archive], ITEMS[:high], ITEMS[:low]]
          },
          'by preservation_type and usage_type' => {
              options: {filter: {preservation_type: 'DERIVATIVE_COPY', usage_type: 'VIEW'}},
              check_params: [ITEMS[:high],ITEMS[:low]]
          },
          'by presservation_type and usage_type without match' => {
              options: {filter: {preservation_type: 'PRESERVATION_MASTER', usage_type: 'THUMBNAIL'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:archive],
              check_params: ITEMS[:archive].merge(representation_code: nil)
          },
          'full item' => {
              params: ITEMS[:high]
          },
          'name missing' => {
              params: ITEMS[:archive].dup.tap {|x| x.delete(:name)},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: Proc.new do |ctx, spec|
                ctx.subject.(*build_params(spec[:params]))
              end,
              params: ITEMS[:archive],
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty preservation_type' => {
              params: ITEMS[:high].merge(preservation_type: ''),
              failure: true,
              errors: {description: ['size cannot be less than 1']}
          }
      },
      retrieve: {
          'get item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:archive]))[model_param].id
              end,
              check_params: ITEMS[:archive]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:archive]))[model_param].id
              end,
              params: ITEMS[:archive].merge(description: 'Public access'),
          },
          'no name change' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:archive]))[model_param].id
              end,
              params: {name: 'OPEN'},
              check_params: ITEMS[:archive],
          },
          'only description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:archive]))[model_param].id
              end,
              params: {description: 'Public access'},
              check_params: ITEMS[:archive].merge(description: 'Public access'),
          },
          'remove description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:high]))[model_param].id
              end,
              params: {description: nil},
              check_params: ITEMS[:high].merge(description: nil),
          },
          'duplicate name' => {
              init: Proc.new do |ctx, spec|
                ctx.create_class.(*build_params(ITEMS[:archive]))[model_param]
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:high]))[model_param].id
              end,
              params: {name: ITEMS[:archive][:name]},
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:high]))[model_param].id
              end,
              params: {description: ''},
              failure: true,
              errors: {description: ['size cannot be less than 1']}
          }
      },
      delete: {
          'existing item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:archive]))[model_param].id
              end,
              check_params: ITEMS[:archive]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
