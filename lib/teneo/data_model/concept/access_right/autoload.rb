# frozen_string_literal: true

module Teneo::DataModel::AccessRight::Contract

  autoload :Base, 'teneo/data_model/concept/access_right/contract/base'
  autoload :Create, 'teneo/data_model/concept/access_right/contract/create'
  autoload :Update, 'teneo/data_model/concept/access_right/contract/update'

end

module Teneo::DataModel::AccessRight::Operation

  MODEL_CLASS = 'Teneo::DataModel::AccessRight'
  include Teneo::DataModel::Concept::CRUD

end
