# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel
  # noinspection RailsParamDefResolve
  class Storage < Base
    self.table_name = 'storages'

    PROTOCOL_LIST = %w'NFS FTP SFTP GDRIVE'

    belongs_to :organization, inverse_of: :storages

    has_many :parameter_values, as: :with_values, class_name: 'Teneo::DataModel::ParameterValue'

    validates :name, uniqueness: {scope: :organization_id}
    validates :protocol, inclusion: {in: PROTOCOL_LIST}

    def self.from_hash(hash, id_tags = [:manifestation_id, :name])
      params = hash.delete(:values)

      item = super(hash, id_tags)

      if params
        item.parameter_values.clear
        params.each do |name, value|
          item.parameter_values <<
              Teneo::DataModel::ParameterValue.from_hash(name: name, value: value,
                                                         with_values_id: item.id,
                                                         with_values_type: item.class.name)
        end
        item.save!
      end
      item
    end

  end
end
