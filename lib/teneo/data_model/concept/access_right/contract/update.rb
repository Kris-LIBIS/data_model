# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Concept::AccessRight::Contract

  class Update < Create

    property :name, writeable: false

  end

end
