# frozen_string_literal: true

module User

  ITEMS = {
      user1: {uuid: '4689fc7b-c949-4904-bc5b-99fec47882f5', email: 'user1@example.com'},
      user2: {uuid: '3c1d6d36-e618-4a38-bebd-8db6b6d3d76f', email: 'user2@example.com', first_name: 'John', last_name: 'Doe'},
      user3: {uuid: '8b482de0-962c-408a-b336-ac0b5ce235da', email: 'user3@example.com', first_name: 'Jane', last_name: 'Doe'},
      user4: {uuid: '73fb2898-875b-4569-90a7-6b8749d39e81', email: 'user4@example.com', first_name: 'John', last_name: 'Fox'},
  }

  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by uuid' => {
              options: {filter: {uuid: ITEMS[:user1][:uuid]}},
              check_params: [ITEMS[:user1]]
          },
          'by email' => {
              options: {filter: {email: ITEMS[:user2][:email]}},
              check_params: [ITEMS[:user2]]
          },
          'by first name' => {
              options: {filter: {first_name: 'John'}},
              check_params: [ITEMS[:user2], ITEMS[:user4]]
          },
          'by last name' => {
              options: {filter: {last_name: 'Doe'}},
              check_params: [ITEMS[:user2], ITEMS[:user3]]
          },
          'by first and last name with match' => {
              options: {filter: {first_name: 'Jane', last_name: 'Doe'}},
              check_params: [ITEMS[:user3]]
          },
          'by first and last name without match' => {
              options: {filter: {first_name: 'Jane', last_name: 'Fox'}},
              check_params: []
          }
      },
      create: {
          'minimal item' => {
              params: ITEMS[:user1],
              check_params: ITEMS[:user1].merge(first_name: nil, last_name: nil)
          },
          'full item' => {
              params: ITEMS[:user2]
          },
          'uuid missing' => {
              params: ITEMS[:user1].reject {|k| k == :uuid},
              failure: true,
              errors: {uuid: ['must be filled', 'must be unique']}
          },
          'email missing' => {
              params: ITEMS[:user1].reject {|k| k == :email},
              failure: true,
              errors: {email: ['must be filled', 'must be unique']}
          },
          'duplicate uuid' => {
              init: Proc.new do |ctx, spec|
                ctx.subject.(*build_params(ITEMS[:user1]))
              end,
              params: ITEMS[:user2].merge(uuid: ITEMS[:user1][:uuid]),
              failure: true,
              errors: {uuid: ['must be unique']}
          },
          'duplicate email' => {
              init: Proc.new do |ctx, spec|
                ctx.subject.(*build_params(ITEMS[:user1]))
              end,
              params: ITEMS[:user2].merge(email: ITEMS[:user1][:email]),
              failure: true,
              errors: {email: ['must be unique']}
          },
          'empty uuid' => {
              params: ITEMS[:user2].merge(uuid: ''),
              failure: true,
              errors: {uuid: ['must be filled', 'must be unique']}
          },
          'empty email' => {
              params: ITEMS[:user2].merge(email: ''),
              failure: true,
              errors: {email: ['must be filled', 'must be unique']}
          }
      },
      retrieve: {
          'get item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user1]))[model_param].id
              end,
              check_params: ITEMS[:user1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with first and last name' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user1]))[model_param].id
              end,
              params: ITEMS[:user1].merge(first_name: 'Jane', last_name: 'Fox'),
          },
          'no uuid change' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user1]))[model_param].id
              end,
              params: {uuid: '02350846-9e55-4937-b478-230d83cb8d60'},
              check_params: ITEMS[:user1],
          },
          'only email change' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user1]))[model_param].id
              end,
              params: {email: 'userx@example.com'},
              check_params: ITEMS[:user1].merge(email: 'userx@example.com'),
          },
          'only first and last name' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user1]))[model_param].id
              end,
              params: {first_name: 'Jane', last_name: 'Fox'},
              check_params: ITEMS[:user1].merge(first_name: 'Jane', last_name: 'Fox'),
          },
          'remove first and last name' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user2]))[model_param].id
              end,
              params: {first_name: nil, last_name: nil},
              check_params: ITEMS[:user2].merge(first_name: nil, last_name: nil),
          },
          'duplicate uuid' => {
              init: Proc.new do |ctx, spec|
                ctx.create_class.(*build_params(ITEMS[:user1]))[model_param]
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user2]))[model_param].id
              end,
              params: {uuid: ITEMS[:user1][:uuid]},
              failure: true,
              errors: {uuid: ['must be unique']},
          },
          'duplicate email' => {
              init: Proc.new do |ctx, spec|
                ctx.create_class.(*build_params(ITEMS[:user1]))[model_param]
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user2]))[model_param].id
              end,
              params: {email: ITEMS[:user1][:email]},
              failure: true,
              errors: {email: ['must be unique']},
          },
          'empty first name' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user2]))[model_param].id
              end,
              params: {first_name: ''},
              failure: true,
              errors: {first_name: ['must be filled']}
          },
          'empty last name' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user2]))[model_param].id
              end,
              params: {last_name: ''},
              failure: true,
              errors: {last_name: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              init: Proc.new do |ctx, spec|
                spec[:id] = ctx.create_class.(*build_params(ITEMS[:user1]))[model_param].id
              end,
              check_params: ITEMS[:user1]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
