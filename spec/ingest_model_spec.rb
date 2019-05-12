# frozen_string_literal: true

require 'support/crud_examples'
require 'data/ingest_model_data'

RSpec.describe 'IngestModel' do

  include_examples 'CRUD operations', IngestModelData

end
