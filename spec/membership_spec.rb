# frozen_string_literal: true

require 'support/crud_examples'
require 'data/membership_data'

RSpec.describe 'Membership' do

  include_examples 'CRUD operations', MembershipData

end
