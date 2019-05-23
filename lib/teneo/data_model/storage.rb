# frozen_string_literal: true
require 'active_support/core_ext/object/with_options'

require_relative 'base'
require_relative 'serializers/hash_serializer'

module Teneo
  module DataModel
    # noinspection RailsParamDefResolve
    class Storage < Base
      self.table_name = 'storages'

      PROTOCOL_LIST = %w'NFS FTP SFTP GDRIVE'

      belongs_to :organization, inverse_of: :storages

      serialize :options, Teneo::DataModel::Serializers::HashSerializer

      validates :name, uniqueness: {scope: :organization_id}
      validates :protocol, inclusion: {in: PROTOCOL_LIST}

    end
  end
end
