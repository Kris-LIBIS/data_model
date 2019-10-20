# frozen_string_literal: true
require_relative 'base'
require_relative 'serializers/symbol_serializer'
require_relative 'serializers/hash_serializer'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class MessageLog < Base
    self.table_name = 'message_logs'

    belongs_to :item
    belongs_to :run

    serialize :severity, Serializers::SymbolSerializer
    serialize :data, Serializers::HashSerializer

  end

end
