# frozen_string_literal: true

require 'support/crud_examples'
require 'data/material_flow_data'

RSpec.describe 'MaterialFlow' do

  include_examples 'CRUD operations', MaterialFlowData

end
