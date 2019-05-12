# frozen_string_literal: true
require_relative 'data_model_data'

module IngestAgreementData

  MODEL = Teneo::DataModel::IngestAgreement

  ITEMS = DataModelData::ITEMS.for(MODEL) +
      DataModelData::ITEMS.slice(:producer1, :producer3, :material_flow1, :material_flow3)

  # noinspection RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.only(MODEL).values
          },
          'by name' => {
              options: {filter: {name: 'ingest 1'}},
              check_params: ITEMS.vslice(:agreement1)
          },
          'by name without match' => {
              options: {filter: {name: 'ingest xxx'}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :agreement1)},
              params: ITEMS[:agreement1]
          },
          'complete item' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :agreement2)},
              params: ITEMS[:agreement2]
          },
          'name missing' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :agreement1)},
              params: ITEMS[:agreement1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'values in scope of organization_id, name must be unique']}
          },
          'duplicate name with different organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :agreement1, :org2)},
              params: ITEMS[:agreement3].deep_merge(data: {name: 'ingest 1'})
          },
          'duplicate name with the same organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :agreement1)},
              params: ITEMS[:agreement2].deep_merge(data: {name: 'ingest 1'}),
              failure: true,
              errors: {name: ['values in scope of organization_id, name must be unique']}
          },
          'empty name' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :agreement1)},
              params: ITEMS[:agreement1].deep_merge(data: {name: ''}),
              failure: true,
              errors: {name: ['must be filled', 'values in scope of organization_id, name must be unique']}
          },
          'adding producer for same organization' => {
              init: -> (ctx, spec) {
                ctx.create_dependencies(ITEMS, spec, :agreement1)
                ctx.create_items(ITEMS, spec, :producer1)
              },
              params: ITEMS[:agreement1].deep_merge(links: {producer_id: :producer1})
          },
          'adding producer for other organization' => {
              init: -> (ctx, spec) {
                ctx.create_dependencies(ITEMS, spec, :agreement1)
                ctx.create_items(ITEMS, spec, :producer3)
              },
              params: ITEMS[:agreement1].deep_merge(links: {producer_id: :producer3}),
              failure: true,
              errors: {producer_id: ['should have the same inst_code as the linked organization']}
          },
          'adding material flow for same organization' => {
              init: -> (ctx, spec) {
                ctx.create_dependencies(ITEMS, spec, :agreement1)
                ctx.create_items(ITEMS, spec, :material_flow1)
              },
              params: ITEMS[:agreement1].deep_merge(links: {material_flow_id: :material_flow1})
          },
          'adding material flow for other organization' => {
              init: -> (ctx, spec) {
                ctx.create_dependencies(ITEMS, spec, :agreement1)
                ctx.create_items(ITEMS, spec, :material_flow3)
              },
              params: ITEMS[:agreement1].deep_merge(links: {material_flow_id: :material_flow3}),
              failure: true,
              errors: {material_flow_id: ['should have the same inst_code as the linked organization']}
          },
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:agreement1].id},
              check_params: ITEMS[:agreement1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'name change' => {
              id: -> (ctx, spec) {spec[:agreement1].id},
              params: {name: 'ingest xxx'},
              check_params: ITEMS[:agreement1][:data].merge(name: 'ingest xxx'),
          },
          'duplicate name OK for different organization' => {
              id: -> (ctx, spec) {spec[:agreement3].id},
              params: {name: 'ingest 1'},
              check_params: ITEMS[:agreement3][:data].merge(name: 'ingest 1'),
          },
          'duplicate name not OK fot the same organization' => {
              id: -> (ctx, spec) {spec[:agreement1].id},
              params: {name: 'ingest 2'},
              failure: true,
              errors: {name: ['values in scope of organization_id, name must be unique']},
          },
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:agreement1].id},
              check_params: ITEMS[:agreement1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
