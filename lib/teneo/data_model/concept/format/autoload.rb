# frozen_string_literal: true

module Teneo::DataModel::Format::Contract

  autoload :Base, 'teneo/data_model/concept/format/contract/base'
  autoload :Create, 'teneo/data_model/concept/format/contract/create'
  autoload :Update, 'teneo/data_model/concept/format/contract/update'

end

module Teneo::DataModel::Format::Operation

  MODEL_CLASS = 'Teneo::DataModel::Format'
  include Teneo::DataModel::Concept::CRUD

end
