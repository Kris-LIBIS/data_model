# frozen_string_literal: true

require 'support/crud_examples'
require 'data/format_data'

RSpec.describe 'Format' do

  include_examples 'CRUD operations', Teneo::DataModel::Format, Format::ITEMS, Format::TESTS

end
