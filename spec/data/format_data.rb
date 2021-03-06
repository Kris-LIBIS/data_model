# frozen_string_literal: true
require_relative 'data_model_data'
module FormatData

  MODEL = Teneo::DataModel::Format

  ITEMS = DataModelData::ITEMS.for(MODEL)

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: 'TIFF'}},
              check_params: ITEMS.vslice(:tiff)
          },
          'by category' => {
              options: {filter: {category: 'IMAGE'}},
              check_params: ITEMS.vslice(:tiff, :jpeg)
          },
          'by name and category' => {
              options: {filter: {name: 'TIFF', category: 'IMAGE'}},
              check_params: ITEMS.vslice(:tiff)
          },
          'by name and category without match' => {
              options: {filter: {name: 'TIFF', category: 'TEXT'}},
              check_params: []
          },
          #TODO: filter on array types and partial text
      },
      create: {
          'minimal item' => {
              params: ITEMS[:tiff],
              check_params: ITEMS[:tiff].deep_merge(data: {description: nil})
          },
          'complete item' => {
              params: ITEMS[:word]
          },
          'name missing' => {
              params: ITEMS[:tiff].deep_reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: -> (ctx, spec) {ctx.create_item(spec, spec[:params])},
              params: ITEMS[:tiff],
              failure: true,
              errors: {name: ['must be unique']},
          },
          'empty description' => {
              params: ITEMS[:jpeg].deep_merge(data: {description: ''}),
              failure: true,
              errors: {description: ['must be filled']}
          },
          'wrong category' => {
              params: ITEMS[:tiff].deep_merge(data: {category: 'BAD'}),
              failure: true,
              errors: {category: ['must be one of: IMAGE, AUDIO, VIDEO, TEXT, TABULAR, PRESENTATION, ARCHIVE, EMAIL, OTHER']}
          },
          'no mimetypes' => {
              params: ITEMS[:tiff].deep_reject {|k| k == :mimetypes},
              failure: true,
              errors: {mimetypes: ['must be filled', 'must be an array of String']}
          },
          'empty mimetypes' => {
              params: ITEMS[:tiff].deep_merge(data: {mimetypes: []}),
              failure: true,
              errors: {mimetypes: ['must be filled', 'must be an array of String']}
          },
          'wrong mimetypes' => {
              params: ITEMS[:tiff].deep_merge(data: {mimetypes: :tiff}),
              failure: true,
              errors: {mimetypes: ['must be an array of String']}
          },
          'bad mimetypes' => {
              params: ITEMS[:tiff].deep_merge(data: {mimetypes: [:tiff]}),
              failure: true,
              errors: {mimetypes: ['must be an array of String']}
          },
          'empty puids' => {
              params: ITEMS[:tiff].deep_merge(data: {puids: []}),
              failure: true,
              errors: {puids: ['must be filled', 'must be an array of String']}
          },
          'no extensions' => {
              params: ITEMS[:tiff].deep_reject {|k| k == :extensions},
              failure: true,
              errors: {extensions: ['must be filled', 'must be an array of String']}
          },
          'empty extensions' => {
              params: ITEMS[:tiff].deep_merge(data: {extensions: []}),
              failure: true,
              errors: {extensions: ['must be filled', 'must be an array of String']}
          },
          'wrong extensions' => {
              params: ITEMS[:tiff].deep_merge(data: {extensions: 123}),
              failure: true,
              errors: {extensions: ['must be an array of String']}
          },
          'bad extensionss' => {
              params: ITEMS[:tiff].deep_merge(data: {extensions: [123]}),
              failure: true,
              errors: {extensions: ['must be an array of String']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              check_params: ITEMS[:tiff]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'full item' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              params: ITEMS[:tiff].deep_merge(
                  data: {
                      description: 'Tagged Image File Format (TIFF)',
                      mimetypes: %w'image/tiff image/x-tiff image/tif image/x-tif application/tiff application/x-tiff application/tif application/x-tif',
                      puids: %w'fmt/353 fmt/154 fmt/153 fmt/156 fmt/155 fmt/152 fmt/202 x-fmt/387 x-fmt/388 x-fmt/399',
                      extensions: %w'tif TIF tiff tifx dng nef'
                  }
              )
          },
          'with description' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              params: ITEMS[:tiff].deep_merge(data: {description: 'Tagged Image File Format (TIFF)'})
          },
          'no name change' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              params: {name: 'TIF_IMAGE'},
              check_params: ITEMS[:tiff]
          },
          'only description' => {
              id: -> (ctx, spec) {spec[:word].id},
              params: {description: 'Some image format'},
              check_params: ITEMS[:word].deep_merge(data: {description: 'Some image format'})
          },
          'remove description' => {
              id: -> (ctx, spec) {spec[:word].id},
              params: {description: nil},
              check_params: ITEMS[:word].deep_merge(data: {description: nil})
          },
          'remove puids' => {
              id: -> (ctx, spec) {spec[:word].id},
              params: {puids: nil},
              saved_params: ITEMS[:word].deep_merge(data: {puids: nil})
          },
          'duplicate name' => {
              id: -> (ctx, spec) {spec[:jpeg].id},
              params: {name: ITEMS[:tiff][:name]},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'empty description' => {
              id: -> (ctx, spec) {spec[:jpeg].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          },
          'wrong category' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              params: {category: 'BAD'},
              failure: true,
              errors: {category: ['must be one of: IMAGE, AUDIO, VIDEO, TEXT, TABULAR, PRESENTATION, ARCHIVE, EMAIL, OTHER']}
          },
          'no mimetypes' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              params: {mimetypes: nil},
              failure: true,
              errors: {mimetypes: ['must be filled', 'must be an array of String']}
          },
          'empty mimetypes' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              params: {mimetypes: []},
              failure: true,
              errors: {mimetypes: ['must be filled', 'must be an array of String']}
          },
          'wrong mimetypes' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              params: {mimetypes: :tiff},
              failure: true,
              errors: {mimetypes: ['must be an array of String']}
          },
          'bad mimetypes' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              params: {mimetypes: [:tiff]},
              failure: true,
              errors: {mimetypes: ['must be an array of String']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:tiff].id},
              check_params: ITEMS[:tiff]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end