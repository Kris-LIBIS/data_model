# frozen_string_literal: true


module Teneo::DataModel::Concept

    autoload :Operation, 'teneo/data_model/concept/operation'
    autoload :Contract, 'teneo/data_model/concept/contract'
    autoload :CRUD, 'teneo/data_model/concept/crud'

end

require 'teneo/data_model/concept/format/autoload'
require 'teneo/data_model/concept/access_right/autoload'
require 'teneo/data_model/concept/retention_policy/autoload'
require 'teneo/data_model/concept/representation_info/autoload'
require 'teneo/data_model/concept/material_flow/autoload'
require 'teneo/data_model/concept/producer/autoload'
require 'teneo/data_model/concept/user/autoload'
require 'teneo/data_model/concept/organization/autoload'
require 'teneo/data_model/concept/storage/autoload'
require 'teneo/data_model/concept/membership/autoload'
require 'teneo/data_model/concept/ingest_agreement/autoload'
require 'teneo/data_model/concept/ingest_model/autoload'
require 'teneo/data_model/concept/manifestation/autoload'
require 'teneo/data_model/concept/converter/autoload'
require 'teneo/data_model/concept/conversion_job/autoload'
require 'teneo/data_model/concept/workflow/autoload'
require 'teneo/data_model/concept/ingest_job/autoload'
require 'teneo/data_model/concept/package/autoload'
require 'teneo/data_model/concept/item/autoload'
