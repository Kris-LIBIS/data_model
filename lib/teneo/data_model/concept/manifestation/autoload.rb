# frozen_string_literal: true

module Teneo::DataModel::Manifestation::Contract

  autoload :Base, 'teneo/data_model/concept/manifestation/contract/base'
  autoload :Create, 'teneo/data_model/concept/manifestation/contract/create'
  autoload :Update, 'teneo/data_model/concept/manifestation/contract/update'

end

module Teneo::DataModel::Manifestation::Operation

  MODEL_CLASS = 'Teneo::DataModel::Manifestation'
  include Teneo::DataModel::Concept::CRUD

end
