# frozen_string_literal: true

require 'support/crud_examples'
require 'data/ingest_job_data'

RSpec.describe 'IngestJob' do

  include_examples 'CRUD operations', IngestJobData

end
