# frozen_string_literal: true

module Teneo::DataModel::RetentionPolicy::Contract

  autoload :Base, 'teneo/data_model/concept/retention_policy/contract/base'
  autoload :Create, 'teneo/data_model/concept/retention_policy/contract/create'
  autoload :Update, 'teneo/data_model/concept/retention_policy/contract/update'

end

module Teneo::DataModel::RetentionPolicy::Operation

  MODEL_CLASS = 'Teneo::DataModel::RetentionPolicy'
  include Teneo::DataModel::Concept::CRUD

end
