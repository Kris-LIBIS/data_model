# frozen_string_literal: true

require 'support/crud_examples'
require 'data/converter_data'

RSpec.describe 'Storage' do

  include_examples 'CRUD operations', ConverterData

end
