# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::Membership::Contract

  class Create < Base

    property :user_id
    property :organization_id
    property :role

    validation name: :default, inherit: true do
      required(:user_id).filled {model_exist? Teneo::DataModel::User}
      required(:organization_id).filled {model_exist? Teneo::DataModel::Organization}
      required(:role).filled(:str?, included_in?: %w'uploader ingester admin') {unique_scope? [:organization_id, :user_id, :role]}
    end

  end

end
