# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ConversionTask < Base
    self.table_name = 'conversion_tasks'

    belongs_to :conversion_workflow, inverse_of: :conversion_tasks
    acts_as_list scope: :conversion_workflow, add_new_at: :bottom

    belongs_to :converter

    has_many :parameter_values, as: :with_values, class_name: 'Teneo::DataModel::ParameterValue'

    validates :conversion_workflow_id, presence: true
    validates :name, presence: true, uniqueness: {scope: :conversion_workflow_id}
    validates :position, presence: true, uniqueness: {scope: :conversion_workflow_id}

    before_validation :init_position

    def init_position
      # noinspection RubyResolve
      self.position ||= self.class.where(conversion_workflow_id: conversion_workflow_id).pluck(:position).max + 1
    end

    def self.from_hash(hash, id_tags = [:conversion_workflow_id, :name])
      workflow_name = hash.delete(:conversion_workflow)
      query = workflow_name ? {name: workflow_name} : {id: hash[:conversion_workflow_id]}
      conversion_workflow = record_finder Teneo::DataModel::ConversionWorkflow, query
      hash[:conversion_workflow_id] = conversion_workflow.id

      params = hash.delete(:values)

      item = super(hash, id_tags) do |item, h|
        item.position = (position = h.delete(:position)) ? position : item.position = item.conversion_workflow.conversion_tasks.count
        if (converter = h.delete(:converter))
          item.converter = record_finder Teneo::DataModel::Converter, name: converter
        end
      end

      if params
        item.parameter_values.clear
        params.each do |name, value|
          item.parameter_values <<
              Teneo::DataModel::ParameterValue.from_hash(name: name, value: value,
                                                         with_values_id: item.id,
                                                         with_values_type: item.class.name)
        end
        item.save!
      end
      item
    end

  end
end
