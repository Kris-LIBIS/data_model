# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class Converter < Base
    self.table_name = 'converters'

    has_many :conversion_jobs
    has_many :parameter_defs, as: :with_parameters

    def self.from_hash(hash, id_tags = [:name])
      parameters = hash.delete('parameters')
      item = super(hash, id_tags)
      parameters.each do |name, definition|
        item.parameter_defs << Teneo::DataModel::ParameterDef.from_hash(definition.
            merge('name' => name, 'with_parameters_id' => item.id, 'with_parameters_type' => item.class.name))
      end
      item
    end
  end

end
