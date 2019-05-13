# frozen_string_literal: true

require 'support/crud_examples'
require 'data/workflow_data'

RSpec.describe 'Workflow' do

  include_examples 'CRUD operations', WorkflowData

end
