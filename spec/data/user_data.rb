# frozen_string_literal: true

module User

  ITEMS = {
      user1: {
          class: Teneo::DataModel::User,
          data: {uuid: 'uuid1', email: 'user1@example.com'}
      },
      user2: {
          class: Teneo::DataModel::User,
          data: {uuid: 'uuid2', email: 'user2@example.com', first_name: 'John', last_name: 'Doe'}
      },
      user3: {
          class: Teneo::DataModel::User,
          data: {uuid: 'uuid3', email: 'user3@example.com', first_name: 'Jane', last_name: 'Doe'}
      },
      user4: {
          class: Teneo::DataModel::User,
          data: {uuid: 'uuid4', email: 'user4@example.com', first_name: 'John', last_name: 'Fox'}
      }
  }

  # noinspection RubyUnusedLocalVariable
  TESTS = {
      index: {
          'get all' => {
              check_params: ITEMS.values
          },
          'by uuid' => {
              options: {filter: {uuid: 'uuid1'}},
              check_params: [ITEMS[:user1]]
          },
          'by email' => {
              options: {filter: {email: 'user2@example.com'}},
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
              check_params: ITEMS[:user1].deep_merge(data: {first_name: nil, last_name: nil})
          },
          'full item' => {
              params: ITEMS[:user2]
          },
          'uuid missing' => {
              params: ITEMS[:user1].deep_reject {|k| k == :uuid},
              failure: true,
              errors: {uuid: ['must be filled', 'must be unique']}
          },
          'email missing' => {
              params: ITEMS[:user1].deep_reject {|k| k == :email},
              failure: true,
              errors: {email: ['must be filled', 'must be unique']}
          },
          'duplicate uuid' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:user1])},
              params: ITEMS[:user2].deep_merge(data: {uuid: 'uuid1'}),
              failure: true,
              errors: {uuid: ['must be unique']}
          },
          'duplicate email' => {
              init: -> (ctx, spec) {ctx.create_item(spec, ITEMS[:user1])},
              params: ITEMS[:user2].deep_merge(data: {email: 'user1@example.com'}),
              failure: true,
              errors: {email: ['must be unique']}
          },
          'empty uuid' => {
              params: ITEMS[:user2].deep_merge(data: {uuid: ''}),
              failure: true,
              errors: {uuid: ['must be filled', 'must be unique']}
          },
          'empty email' => {
              params: ITEMS[:user2].deep_merge(data: {email: ''}),
              failure: true,
              errors: {email: ['must be filled', 'must be unique']}
          }
      },
      retrieve: {
          'get item' => {
              id: -> (ctx, spec) {spec[:user1].id},
              check_params: ITEMS[:user1]
          },
          'wrong id' => {
              id: 0,
              failure: true
          }
      },
      update: {
          'with first and last name' => {
              id: -> (ctx, spec) {spec[:user1].id},
              params: ITEMS[:user1][:data].merge(first_name: 'Jane', last_name: 'Fox'),
          },
          'no uuid change' => {
              id: -> (ctx, spec) {spec[:user1].id},
              params: {uuid: '02350846-9e55-4937-b478-230d83cb8d60'},
              check_params: ITEMS[:user1],
          },
          'only email change' => {
              id: -> (ctx, spec) {spec[:user1].id},
              params: {email: 'userx@example.com'},
              check_params: ITEMS[:user1][:data].merge(email: 'userx@example.com'),
          },
          'only first and last name' => {
              id: -> (ctx, spec) {spec[:user1].id},
              params: {first_name: 'Jane', last_name: 'Fox'},
              check_params: ITEMS[:user1][:data].merge(first_name: 'Jane', last_name: 'Fox'),
          },
          'remove first and last name' => {
              id: -> (ctx, spec) {spec[:user2].id},
              params: {first_name: nil, last_name: nil},
              check_params: ITEMS[:user2][:data].merge(first_name: nil, last_name: nil),
          },
          'duplicate uuid' => {
              id: -> (ctx, spec) {spec[:user2].id},
              params: {uuid: 'uuid1'},
              failure: true,
              errors: {uuid: ['must be unique']},
          },
          'duplicate email' => {
              id: -> (ctx, spec) {spec[:user2].id},
              params: {email: 'user1@example.com'},
              failure: true,
              errors: {email: ['must be unique']},
          },
          'empty first name' => {
              id: -> (ctx, spec) {spec[:user2].id},
              params: {first_name: ''},
              failure: true,
              errors: {first_name: ['must be filled']}
          },
          'empty last name' => {
              id: -> (ctx, spec) {spec[:user2].id},
              params: {last_name: ''},
              failure: true,
              errors: {last_name: ['must be filled']}
          }
      },
      delete: {
          'existing item' => {
              id: -> (ctx, spec) {spec[:user2].id},
              check_params: ITEMS[:user2]
          },
          'non-existing item' => {
              id: 0,
              failure: true
          }
      }
  }

end
