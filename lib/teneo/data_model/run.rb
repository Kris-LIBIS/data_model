# frozen_string_literal: true
require_relative 'base'
require_relative 'serializers/hash_serializer'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Run < Base

    self.table_name = 'runs'

    belongs_to :package
    has_many :status_logs, dependent: :destroy

    serialize :config, Serializers::HashSerializer
    serialize :options, Serializers::HashSerializer
    serialize :properties, Serializers::HashSerializer

  end

end
