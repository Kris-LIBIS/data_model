# frozen_string_literal: true

module Teneo::DataModel::Concept

  module Format

    module Operation
      # Operations
      autoload :Base, 'teneo/data_model/concept/format/operation/base'
      autoload :Create, 'teneo/data_model/concept/format/operation/create'
      autoload :Delete, 'teneo/data_model/concept/format/operation/delete'
      autoload :Edit, 'teneo/data_model/concept/format/operation/edit'
      autoload :Find, 'teneo/data_model/concept/format/operation/find'
      autoload :Index, 'teneo/data_model/concept/format/operation/index'
      autoload :Present, 'teneo/data_model/concept/format/operation/present'
      autoload :Show, 'teneo/data_model/concept/format/operation/show'
      autoload :Update, 'teneo/data_model/concept/format/operation/update'

    end

    module Contract
      # Contracts
      autoload :Base, 'teneo/data_model/concept/format/contract/base'
      autoload :Create, 'teneo/data_model/concept/format/contract/create'
      autoload :Show, 'teneo/data_model/concept/format/contract/show'
      autoload :Update, 'teneo/data_model/concept/format/contract/update'
    end

  end

end
