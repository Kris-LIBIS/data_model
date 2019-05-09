# frozen_string_literal: true

require 'support/crud_examples'
require 'data/organization_data'

RSpec.describe 'Organization' do

  include_examples 'CRUD operations', Teneo::DataModel::Organization, Organization

end
