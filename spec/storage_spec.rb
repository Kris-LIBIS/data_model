# frozen_string_literal: true

require 'support/crud_examples'
require 'data/storage_data'

RSpec.describe 'Storage' do

  include_examples 'CRUD operations', Teneo::DataModel::Storage, Storage

end
