# frozen_string_literal: true
require_relative 'data_model_data'

module IngestJobData

  MODEL =  Teneo::DataModel::IngestJob

  ITEMS = DataModelData::ITEMS.for(MODEL)

  # noinspection RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.only(MODEL).values
          },
          'by name' => {
              options: {filter: {name: 'model 1'}},
              check_params: ITEMS.vslice(:model1)
          },
          'by name without match' => {
              options: {filter: {name: 'model xxx'}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :model1)},
              params: ITEMS[:model1]
          },
          'complete item' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :model2)},
              params: ITEMS[:model2]
          },
          'name missing' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :model1)},
              params: ITEMS[:model1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :model1)},
              params: ITEMS[:model2].deep_merge(data: {name: 'model 1'}),
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty name' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :model1)},
              params: ITEMS[:model1].deep_merge(data: {name: ''}),
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'wrong accessright' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :model1)},
              params: ITEMS[:model1].deep_merge(links: {access_right_id: 0}),
              failure: true,
              errors: {access_right_id: ['Teneo::DataModel::AccessRight with id=0 does not exist']}
          },
          'wrong retention policy' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :model1)},
              params: ITEMS[:model1].deep_merge(links: {retention_policy_id: 0}),
              failure: true,
              errors: {retention_policy_id: ['Teneo::DataModel::RetentionPolicy with id=0 does not exist']}
          },
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:model1].id},
              check_params: ITEMS[:model1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'name change' => {
              id: -> (ctx, spec) {spec[:model1].id},
              params: {name: 'model xxx'},
              check_params: ITEMS[:model1][:data].merge(name: 'model xxx'),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:model1].id},
              params: {name: 'model 2'},
              failure: true,
              errors: {name: ['must be unique']},
          },
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:model1].id},
              check_params: ITEMS[:model1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
