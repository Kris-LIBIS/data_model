# frozen_string_literal: true

require 'support/crud_examples'
require 'data/producer_data'

RSpec.describe 'Producer' do

  include_examples 'CRUD operations', ProducerData

end
