# frozen_string_literal: true

module Teneo::DataModel::StatusLog::Contract

  autoload :Base, 'teneo/data_model/concept/status_log/contract/base'
  autoload :Create, 'teneo/data_model/concept/status_log/contract/create'
  autoload :Update, 'teneo/data_model/concept/status_log/contract/update'

end

module Teneo::DataModel::StatusLog::Operation

  MODEL_CLASS = 'Teneo::DataModel::StatusLog'
  include Teneo::DataModel::Concept::CRUD

end
