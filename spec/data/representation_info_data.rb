# frozen_string_literal: true
require_relative 'data_model_data'

module RepresentationInfoData

  MODEL = Teneo::DataModel::RepresentationInfo
  ITEMS = DataModelData::ITEMS.for(MODEL)

  # noinspection RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'ARCHIVE'}},
              check_params: ITEMS.vslice(:rep_info1)
          },
          'by preservation_type' => {
              options: {filter: {preservation_type: 'DERIVATIVE_COPY'}},
              check_params: ITEMS.vslice(:rep_info2, :rep_info3, :rep_info4)
          },
          'by usage_type' => {
              options: {filter: {usage_type: 'VIEW'}},
              check_params: ITEMS.vslice(:rep_info1, :rep_info2, :rep_info3)
          },
          'by preservation_type and usage_type' => {
              options: {filter: {preservation_type: 'DERIVATIVE_COPY', usage_type: 'VIEW'}},
              check_params: ITEMS.vslice(:rep_info2, :rep_info3)
          },
          'by presservation_type and usage_type without match' => {
              options: {filter: {preservation_type: 'PRESERVATION_MASTER', usage_type: 'THUMBNAIL'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:rep_info1],
              check_params: ITEMS[:rep_info1][:data].merge(representation_code: nil)
          },
          'full item' => {
              params: ITEMS[:rep_info2]
          },
          'name missing' => {
              params: ITEMS[:rep_info1].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:rep_info1])},
              params: ITEMS[:rep_info1],
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty preservation_type' => {
              params: ITEMS[:rep_info2].deep_merge(data: {preservation_type: ''}),
              failure: true,
              errors: {:preservation_type => ["must be filled"]}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:rep_info1].id},
              check_params: ITEMS[:rep_info1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with representation_code' => {
              id: -> (ctx, spec) {spec[:rep_info1].id},
              params: ITEMS[:rep_info1].deep_merge(data: {representation_code: 'ARCHIVE'}),
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:rep_info1].id},
              params: {name: 'OPEN'},
              check_params: ITEMS[:rep_info1],
          },
          'only representation_code' => {
              id: -> (ctx, spec) {spec[:rep_info1].id},
              params: {representation_code: 'ARCHIVE'},
              check_params: ITEMS[:rep_info1][:data].merge(representation_code: 'ARCHIVE'),
          },
          'remove representation_code' => {
              id: -> (ctx, spec) {spec[:rep_info2].id},
              params: {representation_code: nil},
              check_params: ITEMS[:rep_info2][:data].merge(representation_code: nil),
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:rep_info2].id},
              params: {name: ITEMS[:rep_info1][:name]},
              failure: true,
              errors: {name: ['must be filled','must be unique']}
          },
          'empty representation_code' => {
              id: -> (ctx, spec) {spec[:rep_info2].id},
              params: {representation_code: ''},
              failure: true,
              errors: {representation_code: ['size cannot be less than 1']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:rep_info1].id},
              check_params: ITEMS[:rep_info1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
