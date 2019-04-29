# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::User::Contract

  class Update < Create

    property :uuid, writeable: false

  end

end
