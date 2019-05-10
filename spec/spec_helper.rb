# frozen_string_literal: true
require "bundler/setup"
require "teneo/data_model"
require 'trailblazer'

RSpec.configure do |config|

  require 'support/active_record_spec_helper'

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def build_params(*args)
  Teneo::DataModel::Concept::Operation.build_params(*args)
end

def model_param
  Teneo::DataModel::Concept::Operation.result_param(:model)
end

def result_param(p)
  Teneo::DataModel::Concept::Operation.result_param(p)
end

# require 'active_support/core_ext/hash'
#
# class Hash
#   def deep_reject(&block)
#     self.each_with_object({}) do |(k,v), m|
#       m[k] = v.is_a?(Hash) ? v.deep_reject(&block) : v unless block.call(k,v)
#     end
#   end
#
#   def deep_apply(method, &block)
#     self.each_with_object({}) do |(k,v), m|
#       m[k] = v.is_a?(Hash) ? v.deep_apply(method, &block) : v
#     end.send(method, &block)
#   end
#
# end