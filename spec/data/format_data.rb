# frozen_string_literal: true

module Format

  ITEMS = {
      tiff: {name: 'TIFF', category: 'IMAGE', mime_types: %w'image/tiff', extensions: %w'tif'},
      jpeg: {name: 'JPEG', category: 'IMAGE', mime_types: %w'image/jpeg', extensions: %w'jpg'},
      word: {name: 'WORD', category: 'TEXT', description: 'Microsoft Word Document (DOC)',
             mime_types: %w'application/msword application/vnd.msword application/vnd.ms-word',
             extensions: %w'doc wbk',
             puids: %w'fmt/609 fmt/39 x-fmt/273'
      }
  }

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by name' => {
              options: {filter: {name: ITEMS[:tiff][:name]}},
              check_params: [ITEMS[:tiff]]
          },
          'by category' => {
              options: {filter: {category: ITEMS[:tiff][:category]}},
              check_params: [ITEMS[:tiff], ITEMS[:jpeg]]
          },
          'by name and category' => {
              options: {filter: {name: ITEMS[:tiff][:name], category: ITEMS[:jpeg][:category]}},
              check_params: [ITEMS[:tiff]]
          },
          'by name and category without match' => {
              options: {filter: {name: ITEMS[:tiff][:name], category: ITEMS[:word][:category]}},
              check_params: []
          },
          #TODO: filter on array types and partial text
      },
      create: {
          'minimal item' => {
              params: ITEMS[:tiff],
              check_params: ITEMS[:tiff].merge(description: nil)
          },
          'complete item' => {
              params: ITEMS[:word]
          },
          'name missing' => {
              params: ITEMS[:tiff].reject {|k| k == :name},
              failure: true,
              errors: {name: ['must be filled', 'must be unique']}
          },
          'duplicate name' => {
              init: Proc.new {|ctx, spec| ctx.subject.(*build_params(spec[:params]))},
              params: ITEMS[:tiff],
              failure: true,
              errors: {name: ['must be unique']},
          },
          'empty description' => {
              params: ITEMS[:jpeg].merge(description: ''),
              failure: true,
              errors: {description: ['must be filled']}
          },
          'wrong category' => {
              params: ITEMS[:tiff].merge(category: 'BAD'),
              failure: true,
              errors: {category: ['must be one of: IMAGE, AUDIO, VIDEO, TEXT, TABULAR, PRESENTATION, ARCHIVE, EMAIL, OTHER']}
          },
          'no mimetypes' => {
              params: ITEMS[:tiff].reject {|k| k == :mime_types},
              failure: true,
              errors: {mime_types: ['must be filled', 'must be an array of String']}
          },
          'empty mimetypes' => {
              params: ITEMS[:tiff].merge(mime_types: []),
              failure: true,
              errors: {mime_types: ['must be filled', 'must be an array of String']}
          },
          'wrong mimetypes' => {
              params: ITEMS[:tiff].merge(mime_types: :tiff),
              failure: true,
              errors: {mime_types: ['must be an array of String']}
          },
          'bad mimetypes' => {
              params: ITEMS[:tiff].merge(mime_types: [:tiff]),
              failure: true,
              errors: {mime_types: ['must be an array of String']}
          },
          'empty puids' => {
              params: ITEMS[:tiff].merge(puids: []),
              failure: true,
              errors: {puids: ['must be filled', 'must be an array of String']}
          },
          'no extensions' => {
              params: ITEMS[:tiff].reject {|k| k == :extensions},
              failure: true,
              errors: {extensions: ['must be filled', 'must be an array of String']}
          },
          'empty extensions' => {
              params: ITEMS[:tiff].merge(extensions: []),
              failure: true,
              errors: {extensions: ['must be filled', 'must be an array of String']}
          },
          'wrong extensions' => {
              params: ITEMS[:tiff].merge(extensions: 123),
              failure: true,
              errors: {extensions: ['must be an array of String']}
          },
          'bad extensionss' => {
              params: ITEMS[:tiff].merge(extensions: [123]),
              failure: true,
              errors: {extensions: ['must be an array of String']}
          }
      },
      retrieve: {
          'get item' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              check_params: ITEMS[:tiff]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'full item' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              params: ITEMS[:tiff].merge(
                  description: 'Tagged Image File Format (TIFF)',
                  mime_types: %w'image/tiff image/x-tiff image/tif image/x-tif application/tiff application/x-tiff application/tif application/x-tif',
                  puids: %w'fmt/353 fmt/154 fmt/153 fmt/156 fmt/155 fmt/152 fmt/202 x-fmt/387 x-fmt/388 x-fmt/399',
                  extensions: %w'tif TIF tiff tifx dng nef'
              )
          },
          'with description' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              params: ITEMS[:tiff].merge(description: 'Tagged Image File Format (TIFF)')
          },
          'no name change' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              params: {name: 'TIF_IMAGE'},
              check_params: ITEMS[:tiff]
          },
          'only description' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:word]))[model_param].id},
              params: {description: 'Some image format'},
              check_params: ITEMS[:word].merge(description: 'Some image format')
          },
          'remove description' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:word]))[model_param].id},
              params: {description: nil},
              check_params: ITEMS[:word].merge(description: nil)
          },
          'remove puids' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:word]))[model_param].id},
              params: {puids: nil},
              saved_params: ITEMS[:word].merge(puids: nil)
          },
          'duplicate name' => {
              init: Proc.new {|ctx, spec| ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param]; spec[:id] = ctx.create_class.(*build_params(ITEMS[:jpeg]))[model_param].id},
              params: {name: ITEMS[:tiff][:name]},
              failure: true,
              errors: {name: ['must be unique']}
          },
          'empty description' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:jpeg]))[model_param].id},
              params: {description: ''},
              failure: true,
              errors: {description: ['must be filled']}
          },
          'wrong category' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              params: {category: 'BAD'},
              failure: true,
              errors: {category: ['must be one of: IMAGE, AUDIO, VIDEO, TEXT, TABULAR, PRESENTATION, ARCHIVE, EMAIL, OTHER']}
          },
          'no mimetypes' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              params: {mime_types: nil},
              failure: true,
              errors: {mime_types: ['must be filled', 'must be an array of String']}
          },
          'empty mimetypes' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              params: {mime_types: []},
              failure: true,
              errors: {mime_types: ['must be filled', 'must be an array of String']}
          },
          'wrong mimetypes' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              params: {mime_types: :tiff},
              failure: true,
              errors: {mime_types: ['must be an array of String']}
          },
          'bad mimetypes' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              params: {mime_types: ITEMS[:tiff].merge(mime_types: [:tiff])[:mime_types]},
              failure: true,
              errors: {mime_types: ['must be an array of String']}
          }
      },
      delete: {
          'existing item' => {
              init: Proc.new {|ctx, spec| spec[:id] = ctx.create_class.(*build_params(ITEMS[:tiff]))[model_param].id},
              check_params: ITEMS[:tiff]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end