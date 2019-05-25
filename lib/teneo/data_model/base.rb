# frozen_string_literal: true
require 'active_record'
require 'active_support/core_ext/hash/compact'
require 'active_support/core_ext/hash/keys'

module Teneo
  module DataModel
    class Base < ActiveRecord::Base

      def self.array_field(name)
          # self.attr_internal_accessor("#{name}_list")
          self.define_method "#{name}_list" do
            self.send(name).blank? ? '' : self.send(name).join(',')
          end
          self.define_method "#{name}_list=" do |values|
            self.send("#{name}=", [])
            self.send("#{name}=", values.split(',')) unless values.blank?
          end
      end

      def self.from_hash(hash, id_tags = [:name], &block)
        self.create_from_hash(hash.compact, id_tags, &block)
      end

      def self.create_from_hash(hash, id_tags, &block)
        hash = hash.deep_symbolize_keys
        id_tags = id_tags.map(&:to_sym)
        unless id_tags.empty? || id_tags.any? {|k| hash.include?(k)}
          raise ArgumentError, "Could not create '#{self.name}' object from Hash since none of the id tags '#{id_tags.join(',')}' are present"
        end
        tags = id_tags.inject({}) do |h, k|
          v = hash.delete(k)
          h[k] = v if v
          h
        end
        item = tags.empty? ? self.new : self.find_or_initialize_by(tags)
        item.attributes.clear
        block.call(item, hash) if block unless hash.empty?
        item.assign_attributes(tags.merge(hash))
        item.save!
        item
      end

      def to_hash
        result = self.attributes.reject {|k, v| v.blank? || volatile_attributes.include?(k)}
        result = result.to_yaml
        YAML.safe_load(result, symbolize_names: true, permitted_classes: [Time])
      end

      def to_s
        (self.name rescue nil) || "#{self.class.name}_#{self.id}"
      end

      protected

      def volatile_attributes
        %w'id created_at updated_at'
      end

      def copy_attributes(other)
        self.set(
            other.attributes.reject do |k, _|
              volatile_attributes.include? k.to_s
            end.each_with_object({}) do |(k, v), h|
              h[k] = v.duplicable? ? v.dup : v
            end
        )
        self
      end


    end
  end
end