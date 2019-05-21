# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class MaterialFlow < Base
    self.table_name = 'material_flows'

    def self.for_institution(id)
      self.where(inst_id: id)
    end

    has_many :ingest_agreements,
             dependent: :destroy,
             inverse_of: :material_flow

    validates :name, :ext_id, :inst_code, presence: true
    validates :name, uniqueness: {scope: :inst_code, message: 'already taken for this inst_code'}
  end

end
