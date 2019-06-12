# frozen_string_literal: true
require 'active_support/core_ext/object/with_options'

require_relative 'base'

module Teneo
  module DataModel
    # noinspection RailsParamDefResolve
    class Storage < Base
      self.table_name = 'storages'

      PROTOCOL_LIST = %w'NFS FTP SFTP GDRIVE'

      belongs_to :organization, inverse_of: :storages

      has_many :values, as: :with_values

      validates :name, uniqueness: {scope: :organization_id}
      validates :protocol, inclusion: {in: PROTOCOL_LIST}

      def self.from_hash(hash, id_tags = [:manifestation_id, :name])
        values = hash.delete(:values)
        item = super(hash, id_tags)
        if values
          values.each do |name, value|
            item.values << Teneo::DataModel::ParameterValue.from_hash(name: name, value: value,
                                                                      with_values_id: item.id,
                                                                      with_values_type: item.class.name)
          end
          item.save!
        end
        item
      end

    end
  end
end
