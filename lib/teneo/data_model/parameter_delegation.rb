# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ParameterDelegation < Base
    self.table_name = 'parameter_delegations'

    belongs_to :parameter_ref
    belongs_to :delegate, polymorphic: true

  end

end
