# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel
  # noinspection RailsParamDefResolve
  class StorageType < Base
    self.table_name = 'storage_types'

    include WithParameterDefs

    def name
      protocol
    end

    PROTOCOL_LIST = %w'NFS FTP SFTP GDRIVE'

    has_many :storages, inverse_of: :storage_type

    validates :protocol, presence: true, inclusion: {in: PROTOCOL_LIST}

    def self.from_hash(hash, id_tags = [:protocol])
      params = hash.delete(:parameters)
      super(hash, id_tags).params_from_hash(params)
    end

  end
end
