# frozen_string_literal: true
require_relative 'ingest_model_data'

module Manifestation

  # noinspection RubyStringKeysInHashInspection
  ITEMS = {
      rp: {
          class: Teneo::DataModel::RetentionPolicy,
          data: {name: 'PERMANENT', ext_id: 'RP_NONE'}
      },
      public: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'PUBLIC', ext_id: 'AR_PUBLIC'}
      },
      private: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'PRIVATE', ext_id: 'AR_PRIVATE', description: 'Private access'}
      },
      open: {
          class: Teneo::DataModel::AccessRight,
          data: {name: 'OPEN', ext_id: 'AR_PUBLIC'}
      },
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
      model: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model'},
          links: {retention_policy_id: :rp, access_right_id: :ar}
      },
      master: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model 1'},
          links: {retention_policy_id: :rp1, access_right_id: :ar1}
      },
      mod_master: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model 2', description: 'ingest model 2', entity_type: 'entity type 1',
                 user_a: 'a', user_b: 'b', user_c: 'c', identifier: '123', status: 'stored'},
          links: {retention_policy_id: :rp1, access_right_id: :ar1}
      },
      derived: {
          class: Teneo::DataModel::IngestModel,
          data: {name: 'model 3'},
          links: {retention_policy_id: :rp1, access_right_id: :ar1}
      },
  }

  # noinspection RubyStringKeysInHashInspection,RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: [ITEMS[:master], ITEMS[:mod_master], ITEMS[:derived]]
          },
          'by name' => {
              options: {filter: {name: 'model 1'}},
              check_params: [ITEMS[:master]]
          },
          'by name without match' => {
              options: {filter: {name: 'model xxx'}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:master]
          },
          'complete item' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:mod_master]
          },
          'name missing' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:master].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1, :master)},
              params: ITEMS[:mod_master].deep_merge(data: {name: 'model 1'}),
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty name' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:master].deep_merge(data: {name: ''}),
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'wrong accessright' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:master].deep_merge(links: {access_right_id: 0}),
              failure: true,
              errors: {access_right_id: ['Teneo::DataModel::AccessRight with id=0 does not exist']}
          },
          'wrong retention policy' => {
              init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :rp1, :ar1)},
              params: ITEMS[:master].deep_merge(links: {retention_policy_id: 0}),
              failure: true,
              errors: {retention_policy_id: ['Teneo::DataModel::RetentionPolicy with id=0 does not exist']}
          },
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:master].id},
              check_params: ITEMS[:master]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'name change' => {
              id: -> (ctx, spec) {spec[:master].id},
              params: {name: 'model xxx'},
              check_params: ITEMS[:master][:data].merge(name: 'model xxx'),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:master].id},
              params: {name: 'model 2'},
              failure: true,
              errors: {name: ['must be unique']},
          },
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:master].id},
              check_params: ITEMS[:master]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
