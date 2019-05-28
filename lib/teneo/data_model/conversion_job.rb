# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ConversionJob < Base
    self.table_name = 'conversion_jobs'

    belongs_to :manifestation
    belongs_to :conversion

    belongs_to :converter
    has_many :values, as: :with_values

    validates :manifestation_id, presence: true
    validates :name, presence: true, uniqueness: {scope: :manifestation_id}
    validates :position, presence: true, uniqueness: {scope: :manifestation_id}

    def self.from_hash(hash, id_tags = [:manifestation_id, :name])
      values = hash.delete(:values)
      item = super(hash, id_tags) do |item, h|
        item.position = (position = h.delete(:position)) ? position : item.position = item.manifestation.ingest_jobs.count
        if (converter = h.delete(:converter))
          item.converter = Teneo::DataModel::Converter.find_by!(name: converter)
        end
      end
      values.each do |name, value|
        Teneo::DataModel::ParameterValue.from_hash('name' => name, 'value' => value,
                                                                  'with_values_id' => item.id,
                                                                  'with_values_type' => item.class.name)
      end if values
      item
    end

  end

end
