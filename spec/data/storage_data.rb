# frozen_string_literal: true
require_relative 'data_model_data'

module StorageData

  MODEL = Teneo::DataModel::Storage

  ITEMS = DataModelData::ITEMS.for(MODEL)

  # noinspection RubyUnusedLocalVariable,RubyStringKeysInHashInspection
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.only(MODEL).values
          },
          'by name' => {
              options: {filter: {name: 'upload'}},
              check_params: ITEMS.vslice(:storage1, :storage3)
          },
          'by protocol' => {
              options: {filter: {protocol: 'nas'}},
              check_params: ITEMS.vslice(:storage1, :storage3)
          },
          'by name and protocol with match' => {
              options: {filter: {name: 'upload', protocol: 'nas'}},
              check_params: ITEMS.vslice(:storage1, :storage3)
          },
          'by name and protocol without match' => {
              options: {filter: {name: 'upload', protocol: 'ftp'}},
              check_params: []
          }
      },
      create: {
          'regular item' => {
              # init: -> (ctx, spec) {ctx.create_items(ITEMS, spec, :org1)},
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :storage1)},
              params: ITEMS[:storage1],
              check_params: ITEMS[:storage1]
          },
          'name missing' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :storage1)},
              params: ITEMS[:storage1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'values in scope of organization_id, name must be unique']}
          },
          'duplicate name with different organization' => {
              init: -> (ctx, spec) {
                ctx.create_dependencies(ITEMS, spec, :storage1)
                ctx.create_item(spec, ITEMS[:storage1])
                ctx.create_dependencies(ITEMS, spec, :storage3)
              },
              params: ITEMS[:storage3]
          },
          'duplicate name with the same organization' => {
              init: -> (ctx, spec) {
                ctx.create_dependencies(ITEMS, spec, :storage1)
                ctx.create_item(spec, ITEMS[:storage1])
                ctx.create_dependencies(ITEMS, spec, :storage2)
              },
              params: ITEMS[:storage2].deep_merge(data: {name: 'upload'}),
              failure: true,
              errors: {name: ['values in scope of organization_id, name must be unique']}
          },
          'empty name' => {
              init: -> (ctx, spec) {ctx.create_dependencies(ITEMS, spec, :storage1)},
              params: ITEMS[:storage1].deep_merge(data: {name: ''}),
              failure: true,
              errors: {name: ['must be filled', 'values in scope of organization_id, name must be unique']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:storage1].id},
              check_params: ITEMS[:storage1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with protocol and options' => {
              id: -> (ctx, spec) {spec[:storage1].id},
              params: {protocol: 'gdrive', options: {'credentials_file' => 'credentials.json', 'path' => '/data'}},
              check_params: ITEMS[:storage1][:data].merge(protocol: 'gdrive', options: {'credentials_file' => 'credentials.json', 'path' => '/data'}),
          },
          'name change' => {
              id: -> (ctx, spec) {spec[:storage1].id},
              params: {name: 'cloud'},
              check_params: ITEMS[:storage1][:data].merge(name: 'cloud'),
          },
          'duplicate name OK' => {
              id: -> (ctx, spec) {spec[:storage3].id},
              params: {name: 'ftp_server'},
              check_params: ITEMS[:storage3][:data].merge(name: 'ftp_server'),
          },
          'duplicate name not OK' => {
              id: -> (ctx, spec) {spec[:storage1].id},
              params: {name: 'ftp_server'},
              failure: true,
              errors: {name: ['values in scope of organization_id, name must be unique']},
          },
          'empty protocol' => {
              id: -> (ctx, spec) {spec[:storage1].id},
              params: {protocol: ''},
              failure: true,
              errors: {protocol: ['must be filled']}
      },
          'empty options' => {
              id: -> (ctx, spec) {spec[:storage1].id},
              params: {options: ''},
              failure: true,
              errors: {options: ['must be a hash']}
      },
          'remove protocol' => {
              id: -> (ctx, spec) {spec[:storage1].id},
              params: {protocol: nil},
              failure: true,
              errors: {protocol: ['must be filled']}
      },
          'remove options' => {
              id: -> (ctx, spec) {spec[:storage1].id},
              params: {options: nil},
              check_params: ITEMS[:storage1][:data].merge(options: nil),
          }
  },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:storage1].id},
              check_params: ITEMS[:storage1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
