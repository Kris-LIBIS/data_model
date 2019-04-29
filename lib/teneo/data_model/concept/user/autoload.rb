# frozen_string_literal: true

module Teneo::DataModel::User::Contract

  autoload :Base, 'teneo/data_model/concept/user/contract/base'
  autoload :Create, 'teneo/data_model/concept/user/contract/create'
  autoload :Update, 'teneo/data_model/concept/user/contract/update'

end

module Teneo::DataModel::User::Operation

  MODEL_CLASS = 'Teneo::DataModel::User'
  include Teneo::DataModel::Concept::CRUD

end
