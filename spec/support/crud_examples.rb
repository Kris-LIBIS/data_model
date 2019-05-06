# frozen_string_literal: true

require 'teneo/data_model'
require 'awesome_print'
require 'prettyprint'

require 'support/active_record_spec_helper'

RSPEC_DEBUG = true

def spec_desciption(desc, spec)
  "#{spec[:failure] ? 'Failure' : 'Success'} : #{desc}"
end

RSpec.shared_examples 'CRUD operations' do |active_record, item_params, test_data, init_proc = nil|

  # noinspection RubyResolve
  def spec_macro(spec, operation_type:)
    spec[:init] = spec[:init].(self, spec) if spec[:init]
    spec[:init] = nil
    spec.each {|k, v| spec[k] = v.(self.spec) if v.is_a?(Proc)}
    params = spec[:params] || {}
    params = params.merge(id: spec[:id]) if spec[:id]
    params = build_params(params, spec[:options])
    result = subject.(*params)
    pp result if RSPEC_DEBUG
    if spec[:failure]
      expect(result).to be_failure
      pp result["contract.#{operation_type}"]&.errors&.messages if RSPEC_DEBUG
      case operation_type
      when :create
        expect(result[model_param]).not_to be_nil
        expect(result[model_param]).not_to be_persisted
      when :retrieve
        expect(result[model_param]).to be_nil
      when :update
        expect(result[model_param]).not_to be_nil
        expect(result[model_param]).to be_persisted
      when :delete
        expect(result[model_param]).to be_nil
      else
        # Do nothing
      end
      expect(result["contract.#{operation_type}"].errors.messages).to eq spec[:errors] if spec[:errors]
    else
      expect(result).to be_success
      case operation_type
      when :create, :retrieve, :update
        expect(result[model_param]).not_to be_nil
        expect(result[model_param]).to be_persisted
      when :delete
        expect(result[model_param]).not_to be_nil
        expect(result[model_param]).not_to be_persisted
      else
        # Do nothing
      end
      expect(result[model_param]).not_to be_nil
      spec[:check_params] = spec[:check_params] || spec[:params] || {}
      if spec[:check_params].is_a? Array
        expect(result[model_param].count).to eql spec[:check_params].size
        spec[:check_params].each_with_index do |parameters, i|
          parameters.each do |key, value|
            expect(result[model_param][i][key]).to eql value
          end
        end
      else
        pp result[model_param]&.attributes&.inspect if RSPEC_DEBUG
        spec[:check_params].each do |key, value|
          expect(result[model_param].send(key)).to eq value
        end
      end
    end
  end

  context 'Index operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Index'
    }

    let(:create_class) {
      Object.const_get(active_record.name + '::Operation::Create')
    }

    before(:example) do
      init_proc.() if init_proc
      # pp item_params
      item_params.values.each do |params|
        # klass = params.delete(:create_class) || create_class
        result = create_class.(*build_params(params))
        pp result if RSPEC_DEBUG
        expect(result).to be_success
      end
    end

    test_data[:index].each do |desc, spec|

      it "#{spec_desciption(desc, spec)}" do
        spec_macro(spec, operation_type: :index)
      end

    end

  end

  context 'Create operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Create'
    }

    test_data[:create].each do |desc, spec|

      it "#{spec_desciption(desc, spec)}" do
        spec_macro(spec, operation_type: :create)
      end

    end

  end

  context 'Retrieve operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Retrieve'
    }

    let(:create_class) {
      Object.const_get(active_record.name + '::Operation::Create')
    }

    test_data[:retrieve].each do |desc, spec|

      it "#{spec_desciption(desc, spec)}" do
        spec_macro(spec, operation_type: :retrieve)
      end

    end

  end

  context 'Update operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Update'
    }

    let(:create_class) {
      Object.const_get(active_record.name + '::Operation::Create')
    }

    test_data[:update].each do |desc, spec|

      it "#{spec_desciption(desc, spec)}" do
        spec_macro(spec, operation_type: :update)
      end

    end

  end

  context 'Delete operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Delete'
    }

    let(:create_class) {
      Object.const_get(active_record.name + '::Operation::Create')
    }

    test_data[:delete].each do |desc, spec|
      it "#{spec_desciption(desc, spec)}" do
        spec_macro(spec, operation_type: :delete)
      end
    end

  end

end