# frozen_string_literal: true

module Teneo::DataModel::Organization::Contract

  autoload :Base, 'teneo/data_model/concept/organization/contract/base'
  autoload :Create, 'teneo/data_model/concept/organization/contract/create'
  autoload :Update, 'teneo/data_model/concept/organization/contract/update'

end

module Teneo::DataModel::Organization::Operation

  MODEL_CLASS = 'Teneo::DataModel::Organization'
  include Teneo::DataModel::Concept::CRUD

end
