# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection ALL
  class Converter < Base
    self.table_name = 'converters'

    CATEGORY_LIST = %w'converter assembler splitter'

    has_many :conversion_jobs
    has_many :parameter_defs, as: :with_parameters

    array_field :input_formats
    array_field :output_formats

    validates :category, inclusion: {in: CATEGORY_LIST}

    def self.from_hash(hash, id_tags = [:name])
      params = hash.delete(:parameters)
      item = super(hash, id_tags)
      if params
        item.parameter_defs.clear
        params.each do |name, definition|
          item.parameter_defs <<
              Teneo::DataModel::ParameterDef.from_hash(definition.merge(name: name,
                                                                        with_parameters_id: item.id,
                                                                        with_parameters_type: item.class.name))
        end
        item.save!
      end
      item
    end
  end

end
