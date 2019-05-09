# frozen_string_literal: true

module IngestAgreement

  # noinspection RubyStringKeysInHashInspection
  ITEMS = {
      org1: {
          class: Teneo::DataModel::Organization,
          data: {name: 'ORG1', inst_code: 'ORG1'}
      },
      org2: {
          class: Teneo::DataModel::Organization,
          data: {name: 'ORG2', inst_code: 'ORG2'}
      },
      producer: {
          class: Teneo::DataModel::Producer,
          data: {name: 'Producer', ext_id: '1000', inst_code: 'ORG1', agent: 'producer', password: 'abc123'}
      },
      material_flow: {
          class: Teneo::DataModel::MaterialFlow,
          data: {name: 'Ingester', ext_id: '2000', inst_code: 'ORG1'}
      },
      ing_agr1: {
          class: Teneo::DataModel::IngestAgreement,
          data: {name: 'ingest 1'},
          links: {organization_id: :org1}
      },
      ing_agr2: {
          class: Teneo::DataModel::IngestAgreement,
          data: {name: 'ingest 2', project_name: 'project', collection_name: 'collection',
                 contact_ingest: ['contact'], contact_collection: ['contact'], contact_system: ['contact'],
                 collection_description: 'description', ingest_job_name: 'job', collector: 'collector'
          },
          links: {organization_id: :org1}
      },
      ing_agr3: {
          class: Teneo::DataModel::IngestAgreement,
          data: {name: 'ingest 3'},
          links: {organization_id: :org2}
      },
  }

  # noinspection RubyStringKeysInHashInspection,RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: [ITEMS[:ing_agr1], ITEMS[:ing_agr2], ITEMS[:ing_agr3]]
          },
          'by name' => {
              options: {filter: {name: 'ingest 1'}},
              check_params: [ITEMS[:ing_agr1]]
          },
          'by name without match' => {
              options: {filter: {name: 'ingest xxx'}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1)},
              params: ITEMS[:ing_agr1]
          },
          'complete item' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1)},
              params: ITEMS[:ing_agr2]
          },
          'name missing' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1)},
              params: ITEMS[:ing_agr1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'values in scope of organization_id, name must be unique']}
          },
          'duplicate name with different organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1, :org2, :ing_agr1)},
              params: ITEMS[:ing_agr3].deep_merge(data: {name: 'ingest 1'})
          },
          'duplicate name with the same organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1, :org2, :ing_agr1)},
              params: ITEMS[:ing_agr2].deep_merge(data: {name: 'ingest 1'}),
              failure: true,
              errors: {name: ['values in scope of organization_id, name must be unique']}
          },
          'empty name' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1)},
              params: ITEMS[:ing_agr1].deep_merge(data: {name: ''}),
              failure: true,
              errors: {name: ['must be filled', 'values in scope of organization_id, name must be unique']}
          },
          'adding producer for same organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1, :producer)},
              params: ITEMS[:ing_agr1].deep_merge(links: {producer_id: :producer})
          },
          'adding producer for other organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1, :producer, :org2)},
              params: ITEMS[:ing_agr3].deep_merge(links: {producer_id: :producer}),
              failure: true,
              errors: {producer_id: ['should have the same inst_code as the linked organization']}
          },
          'adding material flow for same organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1, :material_flow)},
              params: ITEMS[:ing_agr1].deep_merge(links: {material_flow_id: :material_flow})
          },
          'adding material flow for other organization' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1, :material_flow, :org2)},
              params: ITEMS[:ing_agr3].deep_merge(links: {material_flow_id: :material_flow}),
              failure: true,
              errors: {material_flow_id: ['should have the same inst_code as the linked organization']}
          },
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:ing_agr1].id},
              check_params: ITEMS[:ing_agr1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'name change' => {
              id: -> (ctx, spec) {spec[:ing_agr1].id},
              params: {name: 'ingest xxx'},
              check_params: ITEMS[:ing_agr1][:data].merge(name: 'ingest xxx'),
          },
          'duplicate name OK for different organization' => {
              id: -> (ctx, spec) {spec[:ing_agr3].id},
              params: {name: 'ingest 1'},
              check_params: ITEMS[:ing_agr3][:data].merge(name: 'ingest 1'),
          },
          'duplicate name not OK fot the same organization' => {
              id: -> (ctx, spec) {spec[:ing_agr1].id},
              params: {name: 'ingest 2'},
              failure: true,
              errors: {name: ['values in scope of organization_id, name must be unique']},
          },
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:ing_agr1].id},
              check_params: ITEMS[:ing_agr1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
