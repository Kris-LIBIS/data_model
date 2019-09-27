# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ParameterRef < Base
    self.table_name = 'parameter_refs'

    DELEGATION_REGEX = /^([^#]+)#?(.*)$/

    def self.delegation_search(delegation)
      raise RuntimeError.new('Bad parameter delegation string') unless delegation =~ DELEGATION_REGEX
      Regexp.new "^#{Regexp.escape($1)}#(#{$2.empty? ? '.*' : Regexp.escape($2)})$"
    end

    def self.delegation_host(delegation)
      delegation.gsub(DELEGATION_REGEX) {|_| $1}
    end

    def self.delegation_param(delegation)
      delegation.gsub(DELEGATION_REGEX) {|_| $2}
    end

    array_field(:delegation)

    belongs_to :with_param_refs, polymorphic: true



    validates :name, presence: true
    # validates :delegation, presence: true
    validates :with_param_refs_id, presence: true
    validates :with_param_refs_type, presence: true

    def self.from_hash(hash, id_tags = [:with_param_refs_type, :with_param_refs_id, :name])
      super(hash, id_tags)
    end

    def referenced_parameters(delegation = nil)
      with_param_refs.child_parameters(delegation || self.delegation)
    end

    def referenced_parameter(delegation = nil)
      referenced_parameters(delegation).first
    end

    def delegation_name
      "#{with_param_refs.name}##{name}"
    end

    def to_hash
      # noinspection RubyResolve
        super.tap do |h|
          h[:with_param_refs] = [[with_param_refs_type, with_param_refs_id]]
          h[:export] ||= false
        end
    end

    protected

    def volatile_attributes
      super + %w'with_param_refs_id with_param_refs_type'
    end


  end

end
