# frozen_string_literal: true

module Teneo::DataModel::Membership::Contract

  autoload :Base, 'teneo/data_model/concept/membership/contract/base'
  autoload :Create, 'teneo/data_model/concept/membership/contract/create'
  autoload :Update, 'teneo/data_model/concept/membership/contract/update'

end

module Teneo::DataModel::Membership::Operation

  MODEL_CLASS = 'Teneo::DataModel::Membership'
  include Teneo::DataModel::Concept::CRUD

end
