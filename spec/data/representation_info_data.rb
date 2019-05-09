# frozen_string_literal: true

module RepresentationInfo

  ITEMS = {
      archive: {
          class: Teneo::DataModel::RepresentationInfo,
          data: {name: 'ARCHIVE', preservation_type: 'PRESERVATION_MASTER', usage_type: 'VIEW'}
      },
      high: {
          class: Teneo::DataModel::RepresentationInfo,
          data: {name: 'VIEW_MAIN', preservation_type: 'DERIVATIVE_COPY', usage_type: 'VIEW', representation_code: 'HIGH'}
      },
      low: {
          class: Teneo::DataModel::RepresentationInfo,
          data: {name: 'VIEW', preservation_type: 'DERIVATIVE_COPY', usage_type: 'VIEW', representation_code: 'LOW'}
      },
      thumbnail: {
          class: Teneo::DataModel::RepresentationInfo,
          data: {name: 'THUMBNAIL', preservation_type: 'DERIVATIVE_COPY', usage_type: 'THUMBNAIL', representation_code: 'THUMBNAIL'}
      },
  }

  # noinspection RubyUnusedLocalVariable
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
              check_params: [ITEMS[:high], ITEMS[:low]]
          },
          'by presservation_type and usage_type without match' => {
              options: {filter: {preservation_type: 'PRESERVATION_MASTER', usage_type: 'THUMBNAIL'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:archive],
              check_params: ITEMS[:archive][:data].merge(representation_code: nil)
          },
          'full item' => {
              params: ITEMS[:high]
          },
          'name missing' => {
              params: ITEMS[:archive].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:archive])},
              params: ITEMS[:archive],
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty preservation_type' => {
              params: ITEMS[:high].deep_merge(data: {preservation_type: ''}),
              failure: true,
              errors: {:preservation_type => ["must be filled"]}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:archive].id},
              check_params: ITEMS[:archive]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with representation_code' => {
              id: -> (ctx, spec) {spec[:archive].id},
              params: ITEMS[:archive].deep_merge(data: {representation_code: 'ARCHIVE'}),
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:archive].id},
              params: {name: 'OPEN'},
              check_params: ITEMS[:archive],
          },
          'only representation_code' => {
              id: -> (ctx, spec) {spec[:archive].id},
              params: {representation_code: 'ARCHIVE'},
              check_params: ITEMS[:archive][:data].merge(representation_code: 'ARCHIVE'),
          },
          'remove representation_code' => {
              id: -> (ctx, spec) {spec[:high].id},
              params: {representation_code: nil},
              check_params: ITEMS[:high][:data].merge(representation_code: nil),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:high].id},
              params: {name: ITEMS[:archive][:name]},
              failure: true,
              errors: {name: ['must be filled','must be unique']}
          },
          'empty representation_code' => {
              id: -> (ctx, spec) {spec[:high].id},
              params: {representation_code: ''},
              failure: true,
              errors: {representation_code: ['size cannot be less than 1']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:archive].id},
              check_params: ITEMS[:archive]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
