# frozen_string_literal: true

module Teneo::DataModel::Storage::Contract

  autoload :Base, 'teneo/data_model/concept/storage/contract/base'
  autoload :Create, 'teneo/data_model/concept/storage/contract/create'
  autoload :Update, 'teneo/data_model/concept/storage/contract/update'

end

module Teneo::DataModel::Storage::Operation

  MODEL_CLASS = 'Teneo::DataModel::Storage'
  include Teneo::DataModel::Concept::CRUD

end
