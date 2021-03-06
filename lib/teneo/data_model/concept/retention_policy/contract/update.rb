# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::RetentionPolicy::Contract

  class Update < Create

    property :name, writeable: false

  end

end
