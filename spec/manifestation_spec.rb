# frozen_string_literal: true

require 'support/crud_examples'
require 'data/manifestation_data'

RSpec.describe 'Manifestation' do

  include_examples 'CRUD operations', ManifestationData

end
