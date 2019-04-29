# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Producer::Contract

  class Update < Create

    property :name, writeable: false
    property :inst_code, writeable: false

  end

end
