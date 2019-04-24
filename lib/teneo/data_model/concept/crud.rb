# frozen_string_literal: true
require 'trailblazer'
require 'trailblazer/operation'

module Teneo::DataModel::Concept

  module CRUD

    class Base < ::Teneo::DataModel::Concept::Operation

      step :configure_classes!

      def configure_classes!(ctx, **)
        ctx['model.class'] = get_model_class
        ctx['contract.create.class'] = get_create_contract
        ctx['contract.update.class'] = get_update_contract
      end

    end

    class Index < ::Teneo::DataModel::Concept::Operation

      step :model!

      def model!(ctx, filter: nil, **)
        ctx[result_param(:model)] = filter ? get_model_class.where(filter).all : get_model_class.all
      end

    end

    class Create < Base

      step Trailblazer::Operation::Model(nil, :new)
      step Trailblazer::Operation::Contract.Build name: :create
      step Trailblazer::Operation::Contract.Validate name: :create
      step Trailblazer::Operation::Contract.Persist name: :create

    end

    class Retrieve < Base

      step Trailblazer::Operation::Model nil, :find_by

    end

    class Edit < Base

      step Trailblazer::Operation::Model nil, :find_by
      step Trailblazer::Operation::Contract.Build name: :update

    end

    class Update < Base

      step Trailblazer::Operation::Model nil, :find_by
      step Trailblazer::Operation::Contract.Build name: :update
      step Trailblazer::Operation::Contract.Validate name: :update
      step Trailblazer::Operation::Contract::Persist name: :update

    end

    class Delete < Base

      step Trailblazer::Operation::Model nil, :find_by
      step :delete!

      def delete!(_ctx, model:, **)
        model.destroy
      end

    end

    # def self.[](model_class:, create_contract:, update_contract:)
    #
    #   m = Module.new do
    #
    #     # noinspection RubyResolve
    def self.included(submodule)

      submodule.instance_exec do
        const_set 'Index', Class.new(Teneo::DataModel::Concept::CRUD::Index)
        const_set 'Create', Class.new(Teneo::DataModel::Concept::CRUD::Create)
        const_set 'Retrieve', Class.new(Teneo::DataModel::Concept::CRUD::Retrieve)
        const_set 'Update', Class.new(Teneo::DataModel::Concept::CRUD::Update)
        const_set 'Delete', Class.new(Teneo::DataModel::Concept::CRUD::Delete)
      end

      # submodule.const_set 'Index', Class.new(::Teneo::DataModel::Concept::Operation) do
      #   step :model!
      #   def model!(ctx, filter: nil, **)
      #     ctx[result_param(:model)] = filter ? parent_module.MODEL_CLASS.where(filter) : parent_module.MODEL_CLASS.all
      #   end
      # end
      #
      # submodule.const_set 'Create', Class.new(::Teneo::DataModel::Concept::Operation) do
      #   step Model(submodule.MODEL_CLASS, :new)
      #   step Contract.Build(constant: submodule.CREATE_CONTRACT)
      #   step Contract.Validate
      #   # noinspection RubyResolve
      #   step Contract.Persist
      # end
      #
      # submodule.const_set 'Find', Class.new(::Teneo::DataModel::Concept::Operation) do
      #   step Rescue(ActiveRecord::RecordNotFound) {
      #     step Model parent_module.MODEL_CLASS, :find
      #   }
      #
      #   failure :not_found! #, Output(:failure) => End(:not_found)
      #
      #   def not_found!(ctx, params:, **)
      #     ctx[:errors] ||= []
      #     ctx[:errors] << "Instance of #{parent_module.MODEL_CLASS} with id '#{params[:id]}' not found."
      #   end
      # end
      #
      # submodule.const_set 'Edit', Class.new(::Teneo::DataModel::Concept::Operation) do
      #   step Nested(Find)
      #   step Contract.Build constant: parent_module.UPDATE_CONTRACT
      # end
      #
      # submodule.const_set 'Update', Class.new(::Teneo::DataModel::Concept::Operation) do
      #   step Nested(Edit)
      #   step Contract.Validate
      #   # noinspection RubyResolve
      #   step Contract::Persist
      # end
      #
      # submodule.const_set 'Delete', Class.new(::Teneo::DataModel::Concept::Operation) do
      #   step Nested(Find)
      #   step :delete!
      #
      #   def delete!(_ctx, model:, **)
      #     model.destroy
      #   end
      #
      # end

    end
  end

  #     m.const_set('MODULE_CLASS', model_class)
  #     m.const_set('CREATE_CONTRACT', create_contract)
  #     m.const_set('UPDATE_CONTRACT', update_contract)
  #
  #     m
  #
  #   end
  #
  # end

end
