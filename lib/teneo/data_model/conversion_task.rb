# frozen_string_literal: true
require_relative 'base'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class ConversionTask < Base
    self.table_name = 'conversion_tasks'

    belongs_to :conversion_job, inverse_of: :conversion_tasks
    acts_as_list scope: :conversion_job, add_new_at: :bottom

    belongs_to :converter

    has_many :parameter_values, as: :with_values, class_name: 'Teneo::DataModel::ParameterValue'

    validates :conversion_job_id, presence: true
    validates :name, presence: true, uniqueness: {scope: :conversion_job_id}
    validates :position, presence: true, uniqueness: {scope: :conversion_job_id}

    before_validation :init_position

    def init_position
      # noinspection RubyResolve
      self.position ||= self.class.where(conversion_job_id: conversion_job_id).pluck(:position).max + 1
    end

    def self.from_hash(hash, id_tags = [:conversion_job_id, :name])
      job_name = hash.delete(:conversion_job)
      query = job_name ? {name: job_name} : {id: hash[:conversion_job_id]}
      conversion_job = record_finder Teneo::DataModel::ConversionJob, query
      hash[:conversion_job_id] = conversion_job.id

      params = hash.delete(:values)

      item = super(hash, id_tags) do |item, h|
        item.position = (position = h.delete(:position)) ? position : item.position = item.conversion_job.conversion_tasks.count
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
