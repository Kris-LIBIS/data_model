# frozen_string_literal: true

require 'support/crud_examples'
require 'data/representation_info_data'

RSpec.describe 'RepresentationInfo' do

  include_examples 'CRUD operations', RepresentationInfoData

end
