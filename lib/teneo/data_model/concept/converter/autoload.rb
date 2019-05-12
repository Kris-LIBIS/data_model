# frozen_string_literal: true

module Teneo::DataModel::Converter::Contract

  autoload :Base, 'teneo/data_model/concept/converter/contract/base'
  autoload :Create, 'teneo/data_model/concept/converter/contract/create'
  autoload :Update, 'teneo/data_model/concept/converter/contract/update'

end

module Teneo::DataModel::Converter::Operation

  MODEL_CLASS = 'Teneo::DataModel::Converter'
  include Teneo::DataModel::Concept::CRUD

end
