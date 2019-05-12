# frozen_string_literal: true
require 'trailblazer'
require 'trailblazer/operation'
require 'active_record/errors'

module Teneo::DataModel::Concept::CRUD

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
    step Trailblazer::Operation::Contract::Build name: :create
    step Trailblazer::Operation::Contract::Validate name: :create
    step Trailblazer::Operation::Contract::Persist name: :create

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
    rescue ActiveRecord::ActiveRecordError
      return false
    end

  end

  def self.included(submodule)

    submodule.instance_exec do
      const_set 'Index', Class.new(Teneo::DataModel::Concept::CRUD::Index)
      const_set 'Create', Class.new(Teneo::DataModel::Concept::CRUD::Create)
      const_set 'Retrieve', Class.new(Teneo::DataModel::Concept::CRUD::Retrieve)
      const_set 'Update', Class.new(Teneo::DataModel::Concept::CRUD::Update)
      const_set 'Delete', Class.new(Teneo::DataModel::Concept::CRUD::Delete)
    end

  end

end
