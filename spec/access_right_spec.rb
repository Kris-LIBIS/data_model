# frozen_string_literal: true

require 'support/crud_examples'
require 'data/access_right_data'

RSpec.describe 'AccessRight' do

  include_examples 'CRUD operations', AccessRightData

end
