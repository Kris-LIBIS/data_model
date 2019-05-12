# frozen_string_literal: true

require 'support/crud_examples'
require 'data/retention_policy_data'

RSpec.describe 'RetentionPolicy' do

  include_examples 'CRUD operations', RetentionPolicyData

end
