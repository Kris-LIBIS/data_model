# frozen_string_literal: true

require 'teneo/data_model'
require 'awesome_print'
require 'prettyprint'

require 'support/active_record_spec_helper'

RSPEC_DEBUG = true

def spec_desciption(desc, spec)
  "#{spec[:failure] ? 'Failure' : 'Success'} : #{desc}"
end

RSpec.shared_examples 'CRUD operations' do |active_record, data_module|

  def print_result(result)
    return unless RSPEC_DEBUG
    if result.success?
      puts 'OK'
      pp result[model_param]
    else
      puts 'FAILED'
      pp result
    end
  end
  
  def create_item(spec, params, create_class = nil)
    create_class = Object.const_get(params[:class].to_s + '::Operation::Create') if params[:class]
    result = create_class.(*make_params(spec, params))
    print_result(result)
    expect(result.success?).to be_truthy
    result[model_param]
  end

  def create_items(item_params, spec, *keys)
    item_params.each do |key, params|
      next unless keys.empty? || keys.include?(key)
      spec[key] = create_item(spec, params, create_class)
    end
  end

  def make_params(spec, params)
    params ||= {}
    data = (params[:data] || params).dup
    params[:links]&.each do |k, v|
      o = spec[v]
      data[k] = o.id
    end
    build_params(data)
  end

  def make_params_for_macro(spec)
    params = spec[:params] || {}
    data = (params[:data] || params).dup
    data[:id] = spec[:id] if spec[:id]
    params[:links]&.each do |k, v|
      o = spec[v]
      data[k] = o.id
    end
    build_params(data, spec[:options])
  end

  # noinspection RubyResolve
  def spec_macro(spec, operation_type:)
    spec[:init] = spec[:init].(self, spec) if spec[:init]
    spec[:init] = nil
    spec.each {|k, v| spec[k] = v.(self, spec) if v.is_a?(Proc)}
    spec[:params] ||= {}
    params = make_params_for_macro(spec)
    result = subject.(*params)
    print_result(result)
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
      check_params = spec[:check_params] || spec[:params]
      if check_params.is_a? Array
        expect(result[model_param].count).to eql spec[:check_params].size
        spec[:check_params].each_with_index do |parameters, i|
          parameters = parameters[:data] if parameters.has_key?(:data)
          parameters.each do |key, value|
            expect(result[model_param][i][key]).to eql value
          end
        end
      else
        pp result[model_param]&.attributes&.inspect if RSPEC_DEBUG
        check_params = check_params[:data] if check_params.has_key?(:data)
        check_params.each do |key, value|
          expect(result[model_param].send(key)).to eq value
        end
      end
    end
  end

  let(:create_class) {
    Object.const_get(active_record.name + '::Operation::Create')
  }

  # let(:data_module) { data_module }

  context 'Index operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Index'
    }

    data_module.const_get('TESTS')[:index].each do |desc, spec|

      it "#{spec_desciption(desc, spec)}" do
        create_items(data_module.const_get('ITEMS'), spec)
        spec_macro(spec, operation_type: :index)
      end

    end

  end

  context 'Create operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Create'
    }

    data_module.const_get('TESTS')[:create].each do |desc, spec|

      it "#{spec_desciption(desc, spec)}" do
        spec_macro(spec, operation_type: :create)
      end

    end

  end

  context 'Retrieve operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Retrieve'
    }

    data_module.const_get('TESTS')[:retrieve].each do |desc, spec|

      it "#{spec_desciption(desc, spec)}" do
        create_items(data_module.const_get('ITEMS'), spec)
        spec_macro(spec, operation_type: :retrieve)
      end

    end

  end

  context 'Update operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Update'
    }

    data_module.const_get('TESTS')[:update].each do |desc, spec|

      it "#{spec_desciption(desc, spec)}" do
        create_items(data_module.const_get('ITEMS'), spec)
        spec_macro(spec, operation_type: :update)
      end

    end

  end

  context 'Delete operation' do

    subject {
      Object.const_get active_record.name + '::Operation::Delete'
    }

    data_module.const_get('TESTS')[:delete].each do |desc, spec|
      it "#{spec_desciption(desc, spec)}" do
        # data_module.const_get('ITEMS').each {|key, params| spec[key] = create_item(spec, params, create_class)}
        create_items(data_module.const_get('ITEMS'), spec)
        spec_macro(spec, operation_type: :delete)
      end
    end

  end

end