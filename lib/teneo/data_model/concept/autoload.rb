# frozen_string_literal: true


module Teneo::DataModel

  module Concept

    autoload :Operation, 'teneo/data_model/concept/operation'
    autoload :CRUD, 'teneo/data_model/concept/crud'
    autoload :Contract, 'teneo/data_model/concept/contract'

  end

end

require 'teneo/data_model/concept/format/autoload'
require 'teneo/data_model/concept/access_right/autoload'
