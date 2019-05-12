# frozen_string_literal: true
require_relative 'data_model_data'

module ManifestationData

  MODEL = Teneo::DataModel::Manifestation

  ITEMS = DataModelData::ITEMS.for(MODEL)

  # noinspection RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.only(MODEL).values
          },
          'by name' => {
              options: {filter: {name: 'manifestation 1'}},
              check_params: ITEMS.vslice(:manifestation1)
          },
          'by name without match' => {
              options: {filter: {name: 'manifestation xxx'}},
              check_params: []
          },
          'by label' => {
              options: {filter: {label: 'Label 1'}},
              check_params: ITEMS.vslice(:manifestation1, :manifestation3)
          },
          'by label for model' => {
              options: -> (ctx, spec) {{filter: {ingest_model_id: spec[:model1].id, label: 'Label 1'}}},
              check_params: ITEMS.vslice(:manifestation1)
          }
      },
      create: {
          'regular item' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :manifestation1)},
              params: ITEMS[:manifestation1]
          },
          'with from relation' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :manifestation2)},
              params: ITEMS[:manifestation2]
          },
          'name missing' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :manifestation1)},
              params: ITEMS[:manifestation1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'values in scope of ingest_model_id, name must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {
                ctx.create_dependencies(ITEMS, spec, :manifestation2)
                ctx.create_items(ITEMS, spec, :manifestation1)
              },
              params: ITEMS[:manifestation2].deep_merge(data: {name: 'manifestation 1'}),
              failure: true,
              errors: {name: ['values in scope of ingest_model_id, name must be unique']}
          },
          'empty name' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :manifestation1)},
              params: ITEMS[:manifestation1].deep_merge(data: {name: ''}),
              failure: true,
              errors: {name: ['must be filled', 'values in scope of ingest_model_id, name must be unique']}
          },
          'from other ingest model' => {
              init: -> (ctx, spec) {
                ctx.create_dependencies(ITEMS, spec, :manifestation4)
                ctx.create_items(ITEMS,spec,:manifestation1)
              },
              params: ITEMS[:manifestation4].deep_merge(links: {from_id: :manifestation1}),
              failure: true,
              errors: {from_id: ['should refer to a manifestaion of the same ingest model']}
          },
          'from with higer order' => {
              init: -> (ctx, spec) {
                ctx.create_dependencies(ITEMS, spec, :manifestation3)
                ctx.create_items(ITEMS,spec,:manifestation4)
              },
              params: ITEMS[:manifestation3].deep_merge(links: {from_id: :manifestation4}),
              failure: true,
              errors: {from_id: ['should refer to a manifestation with lower order rank', 'should refer to a manifestaion of the same ingest model']}
          },
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:manifestation1].id},
              check_params: ITEMS[:manifestation1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'name change' => {
              id: -> (ctx, spec) {spec[:manifestation1].id},
              params: {name: 'manifestation x'},
              check_params: ITEMS[:manifestation1][:data].merge(name: 'manifestation x'),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:manifestation1].id},
              params: {name: 'manifestation 2'},
              failure: true,
              errors: {name: ['values in scope of ingest_model_id, name must be unique']},
          },
          'duplicate order for same ingest_model' => {
              id: -> (ctx, spec) {spec[:manifestation2].id},
              params: {order: 1},
              failure: true,
              errors: {order: ['values in scope of ingest_model_id, order must be unique']},
          },
          'duplicate order for different ingest_model' => {
              id: -> (ctx, spec) {spec[:manifestation3].id},
              params: {order: 1},
              check_params: ITEMS[:manifestation3][:data].merge(order: 1),
          },
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:manifestation2].id},
              check_params: ITEMS[:manifestation2]
          },
          'item in use' => {
              id: -> (ctx, spec) {spec[:manifestation1].id},
              failure: true,
              errors: nil
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
