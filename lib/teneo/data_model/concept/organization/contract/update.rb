# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Organization::Contract

  class Update < Create

    property :name, writeable: false

  end

end
