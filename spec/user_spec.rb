# frozen_string_literal: true

require 'support/crud_examples'
require 'data/user_data'

RSpec.describe 'User' do

  include_examples 'CRUD operations', UserData

end
