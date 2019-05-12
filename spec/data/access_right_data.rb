# frozen_string_literal: true

require_relative 'data_model_data'

module AccessRightData

  MODEL = Teneo::DataModel::AccessRight

  ITEMS = DataModelData::ITEMS.for(MODEL)

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'PUBLIC'}},
              check_params: ITEMS.vslice(:access_right1)
          },
          'by ext_id' => {
              options: {filter: {ext_id: 'AR_PUBLIC'}},
              check_params: ITEMS.vslice(:access_right1, :access_right3)
          },
          'by name and ext_id' => {
              options: {filter: {name: 'OPEN', ext_id: 'AR_PUBLIC'}},
              check_params: ITEMS.vslice(:access_right3)
          },
          'by name and ext_id without match' => {
              options: {filter: {name: 'PUBLIC', ext_id: 'AR_PRIVATE'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:access_right1],
              check_params: ITEMS[:access_right1].deep_merge(data: {description: nil})
          },
          'full item' => {
              params: ITEMS[:access_right2]
          },
          'name missing' => {
              params: ITEMS[:access_right1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_item(spec, spec[:params])},
              params: ITEMS[:access_right1],
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              params: ITEMS[:access_right2].deep_merge(data: {description: ''}),
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:access_right1].id},
              check_params: ITEMS[:access_right1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'change description' => {
              id: -> (ctx, spec) {spec[:access_right1].id},
              params: {description: 'Public access'},
              check_params: ITEMS[:access_right1].deep_merge(data: {description: 'Public access'})
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:access_right1].id},
              params: {name: 'SEMI-PUBLIC'},
              check_params: ITEMS[:access_right1]
          },
          'remove description' => {
              id: -> (ctx, spec) {spec[:access_right2].id},
              params: {description: nil},
              check_params: ITEMS[:access_right2].deep_merge(data: {description: nil}),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:access_right2].id},
              params: {name: ITEMS[:access_right1][:data][:name]},
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:access_right2].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:access_right1].id},
              check_params: ITEMS[:access_right1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
