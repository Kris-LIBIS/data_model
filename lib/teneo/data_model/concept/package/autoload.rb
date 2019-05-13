# frozen_string_literal: true

module Teneo::DataModel::Package::Contract

  autoload :Base, 'teneo/data_model/concept/package/contract/base'
  autoload :Create, 'teneo/data_model/concept/package/contract/create'
  autoload :Update, 'teneo/data_model/concept/package/contract/update'

end

module Teneo::DataModel::Package::Operation

  MODEL_CLASS = 'Teneo::DataModel::Package'
  include Teneo::DataModel::Concept::CRUD

end
