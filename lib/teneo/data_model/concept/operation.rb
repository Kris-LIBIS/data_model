# frozen_string_literal: true
require 'trailblazer'
require 'trailblazer/operation'

class Teneo::DataModel::Concept::Operation < ::Trailblazer::Operation
  V21 = (Trailblazer::VERSION =~ /^2\.1/)

  # include Model
  # extend Trailblazer::Operation::Contract::DSL

  def self.build_params(params = {}, options = {})
    p = V21 ? {params: params} : params
    V21 ? [p.merge(options)] : [p || {}, options || {}]
  end

  def self.result_param(param)
    V21 ? param.to_sym : param.to_s
  end

  def result_param(param)
    self.class.result_param(param)
  end

  def parent_module
    self.class.parent_module
  end

  def get_model_class
    self.class.get_model_class
  end

  def get_create_contract
    self.class.get_create_contract
  end

  def get_update_contract
    self.class.get_update_contract
  end

  def self.parent_module
    Object.const_get(self.name.split('::').reverse.drop(1).reverse.join('::'))
  end

  def self.get_model_class
    Object.const_get(parent_module.const_get('MODEL_CLASS'))
  end

  def self.get_create_contract
    Object.const_get(parent_module.const_get('MODEL_CLASS') + '::Contract::Create')
  end

  def self.get_update_contract
    Object.const_get(parent_module.const_get('MODEL_CLASS') + '::Contract::Update')
  end

end
