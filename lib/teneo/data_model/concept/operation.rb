# frozen_string_literal: true
require 'trailblazer'
require 'trailblazer/operation'

module Teneo::DataModel::Concept

  class Operation < ::Trailblazer::Operation
    # include Model
    # extend Trailblazer::Operation::Contract::DSL

    # class ToHash < Operation
    #
    # end
    #
    # class LoadFromYaml < Operation
    #   step :load_yaml!
    #   step :create_model!
    # end

    V21 = (Trailblazer::VERSION =~ /^2\.1/)

    def self.[](params, options = {})
      p = V21 ? {params: params} : params
      p = params ? p : {}
      V21 ? self.call(p.merge(options)) : self.call(p, options)
    end

  end

end
