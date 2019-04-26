# frozen_string_literal: true

module Teneo::DataModel::RepresentationInfo::Contract

  autoload :Base, 'teneo/data_model/concept/representation_info/contract/base'
  autoload :Create, 'teneo/data_model/concept/representation_info/contract/create'
  autoload :Update, 'teneo/data_model/concept/representation_info/contract/update'

end

module Teneo::DataModel::RepresentationInfo::Operation

  MODEL_CLASS = 'Teneo::DataModel::RepresentationInfo'
  include Teneo::DataModel::Concept::CRUD

end
