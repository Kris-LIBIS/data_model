# frozen_string_literal: true

module Teneo::DataModel::Concept

  module AccessRight

    module Contract
      # Contracts
      autoload :Base, 'teneo/data_model/concept/access_right/contract/base'
      autoload :Create, 'teneo/data_model/concept/access_right/contract/create'
      autoload :Update, 'teneo/data_model/concept/access_right/contract/update'
    end

    module Operation

      MODEL_CLASS = Teneo::DataModel::AccessRight
      CREATE_CONTRACT = Teneo::DataModel::Concept::AccessRight::Contract::Create
      UPDATE_CONTRACT = Teneo::DataModel::Concept::AccessRight::Contract::Update

      include CRUD

    end

  end

end
