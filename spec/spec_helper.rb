# frozen_string_literal: true
require "bundler/setup"
require "teneo/data_model"

RSpec.configure do |config|

  require 'active_record_spec_helper'

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VER='2.0'
def build_params(params = nil, options = {})
  p = VER=='2.1' ? {params: params} : params
  p = params ? p : {}
  VER=='2.1' ? [p.merge(options)] : [p, options]
end
def model_param
  VER=='2.1' ? :model : 'model'
end
