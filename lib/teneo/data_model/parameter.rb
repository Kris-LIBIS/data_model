# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class Parameter < Base
    self.table_name = 'parameters'

    DATA_TYPE_LIST = %w'string integer float bool hash array array_string array_integer array_float array_bool'

    belongs_to :with_parameters, polymorphic: true

    has_many :references, class_name: ParameterReference.name, foreign_key: :source_id, dependent: :destroy
    has_many :referenced, class_name: ParameterReference.name, foreign_key: :target_id, dependent: :destroy

    has_many :targets, through: :references, dependent: :destroy
    has_many :sources, through: :referenced, dependent: :destroy

    def param_targets
      targets.reload
    end

    def param_sources
      sources.reload
    end

    # noinspection RubyResolve
    after_touch :clear_association_cache

    validates :name, presence: true
    validates :with_parameters_id, presence: true
    validates :with_parameters_type, presence: true

    def self.from_hash(hash, id_tags = [:with_parameters_type, :with_parameters_id, :name])
      super(hash, id_tags)
    end

    REFERENCE_REGEX = /^(([^#]*)#)?(.*)$/

    def self.reference_search(reference)
      raise RuntimeError.new("Bad parameter reference: #{reference}") unless reference =~ REFERENCE_REGEX
      Regexp.new "^#{Regexp.escape($2)}#(#{$3.empty? ? '.*' : Regexp.escape($3)})$"
    end

    def self.reference_split(reference)
      return [] unless reference =~ REFERENCE_REGEX
      [$2, $3]
    end

    def self.reference_host(reference)
      reference.gsub(REFERENCE_REGEX) { |_| $2 }
    end

    def self.reference_param(reference)
      reference.gsub(REFERENCE_REGEX) { |_| $3 }
    end

    def reference_name
      name =~ /#/ ? name : "#{with_parameters.name}##{name}"
    end

    def <<(param)
      targets << param
    end

    def reference(target)
      targets << target
    end

    def dereference(target)
      targets.destroy(target)
    end

    def dereference_from(source)
      sources.destroy(source)
    end

    attribute :target_list

    def target_list
      targets.map(&:reference_name)
    end

    def target_list=(list)
      return unless with_parameters && id
      targets.clear
      list = list.split(/\s*,\s*/) unless list.is_a?(Array)
      list.each do |target|
        host, param = Parameter::reference_split(target)
        target_host = with_parameters.parameter_children.find { |child| child.name == host }
        next unless target_host
        target_param = target_host.parameters.find_by!(name: param)
        reference(target_param)
      rescue ActiveRecord::RecordNotFound
        raise RuntimeError,
              "Parameter #{param} not found in #{target_host.class} '#{target_host.name}' for #{name}"
      end
      save!
    end

    def target_candidates(unmapped: true)
      (targets.all + with_parameters.child_parameters(export_only: true, unmapped_only: unmapped)).uniq
    end

    def to_hash
      # noinspection RubyResolve
      super.tap do |h|
        h[:with_parameters] = [[with_parameters_type, with_parameters_id]]
        h[:export] ||= false
        h[:references] = targets.map(&:reference_name)
      end
    end

    def value
      default.nil? ? targets.map { |d| d.value }.compact.first : default
    end

    protected

    def volatile_attributes
      super + %w'with_parameters_id with_parameters_type'
    end

  end

end
