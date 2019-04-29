# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::User::Contract

  class Create < Base

    property :uuid
    property :email
    property :first_name
    property :last_name

    validation name: :default, inherit: true do
      required(:uuid).filled(:str?) {unique? :uuid}
      required(:email).filled(:str?) {unique? :email}
      optional(:first_name).maybe(:str?, :filled?)
      optional(:last_name).maybe(:str?, :filled?)
    end

  end

end
