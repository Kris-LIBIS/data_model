# frozen_string_literal: true

module Teneo::DataModel::ConversionJob::Contract

  autoload :Base, 'teneo/data_model/concept/conversion_job/contract/base'
  autoload :Create, 'teneo/data_model/concept/conversion_job/contract/create'
  autoload :Update, 'teneo/data_model/concept/conversion_job/contract/update'

end

module Teneo::DataModel::ConversionJob::Operation

  MODEL_CLASS = 'Teneo::DataModel::ConversionJob'
  include Teneo::DataModel::Concept::CRUD

end
