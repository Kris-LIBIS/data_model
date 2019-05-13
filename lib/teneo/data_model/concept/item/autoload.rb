# frozen_string_literal: true

module Teneo::DataModel::Item::Contract

  autoload :Base, 'teneo/data_model/concept/item/contract/base'
  autoload :Create, 'teneo/data_model/concept/item/contract/create'
  autoload :Update, 'teneo/data_model/concept/item/contract/update'

end

module Teneo::DataModel::Item::Operation

  MODEL_CLASS = 'Teneo::DataModel::Item'
  include Teneo::DataModel::Concept::CRUD

end
