# frozen_string_literal: true

require 'support/crud_examples'
require 'data/ingest_agreement_data'

RSpec.describe 'IngestAgreement' do

  include_examples 'CRUD operations', Teneo::DataModel::IngestAgreement, IngestAgreement

end
