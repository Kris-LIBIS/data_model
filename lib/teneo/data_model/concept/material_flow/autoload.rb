# frozen_string_literal: true

module Teneo::DataModel::MaterialFlow::Contract

  autoload :Base, 'teneo/data_model/concept/material_flow/contract/base'
  autoload :Create, 'teneo/data_model/concept/material_flow/contract/create'
  autoload :Update, 'teneo/data_model/concept/material_flow/contract/update'

end

module Teneo::DataModel::MaterialFlow::Operation

  MODEL_CLASS = 'Teneo::DataModel::MaterialFlow'
  include Teneo::DataModel::Concept::CRUD

end
