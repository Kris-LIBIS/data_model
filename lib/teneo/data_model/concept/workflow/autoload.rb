# frozen_string_literal: true

module Teneo::DataModel::Workflow::Contract

  autoload :Base, 'teneo/data_model/concept/workflow/contract/base'
  autoload :Create, 'teneo/data_model/concept/workflow/contract/create'
  autoload :Update, 'teneo/data_model/concept/workflow/contract/update'

end

module Teneo::DataModel::Workflow::Operation

  MODEL_CLASS = 'Teneo::DataModel::Workflow'
  include Teneo::DataModel::Concept::CRUD

end
