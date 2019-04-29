# frozen_string_literal: true

module Teneo::DataModel::Producer::Contract

  autoload :Base, 'teneo/data_model/concept/producer/contract/base'
  autoload :Create, 'teneo/data_model/concept/producer/contract/create'
  autoload :Update, 'teneo/data_model/concept/producer/contract/update'

end

module Teneo::DataModel::Producer::Operation

  MODEL_CLASS = 'Teneo::DataModel::Producer'
  include Teneo::DataModel::Concept::CRUD

end
