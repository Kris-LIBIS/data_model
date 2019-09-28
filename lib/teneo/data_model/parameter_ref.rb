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

    def self.delegation_split(delegation)
      return [] unless delegation =~ DELEGATION_REGEX
      [$1, $2]
    end

    def self.delegation_host(delegation)
      delegation.gsub(DELEGATION_REGEX) { |_| $1 }
    end

    def self.delegation_param(delegation)
      delegation.gsub(DELEGATION_REGEX) { |_| $2 }
    end

    array_field(:delegation)

    belongs_to :with_param_refs, polymorphic: true

    has_many :parameter_delegations, as: :delegate
    has_many :parameter_refs, through: :parameter_delegations

    def delegates
      ParameterDelegation.where(parameter_ref: self).map(&:delegate)
    end

    def <<(param)
      ParameterDelegation.create(parameter_ref: self, delegate: param).save!
    end

    def >>(param)
      param.parameter_delegations.where(parameter_ref: self).delete
    end

    validates :name, presence: true
    # validates :delegation, presence: true
    validates :with_param_refs_id, presence: true
    validates :with_param_refs_type, presence: true

    def self.from_hash(hash, id_tags = [:with_param_refs_type, :with_param_refs_id, :name])
      super(hash, id_tags)
    end

    def delegation_name
      "#{with_param_refs.name}##{name}"
    end

    def to_hash
      # noinspection RubyResolve
      super.tap do |h|
        h[:host] = [[with_param_refs_type, with_param_refs_id]]
        h[:export] ||= false
        h[:delegation] = delegates.map(&:delegation_name)
      end
    end

    def value
      default.nil? ? delegates.map { |d| d.value }.compact.first : default
    end

    protected

    def volatile_attributes
      super + %w'with_param_refs_id with_param_refs_type'
    end


  end

end
