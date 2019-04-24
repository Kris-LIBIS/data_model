require 'active_record_spec_helper'

require 'teneo/data_model'

require 'awesome_print'

RSpec.describe Teneo::DataModel::Concept::AccessRight::Operation::Update do
  let(:minimal_params) {
    Hash[:name, 'PUBLIC', :ext_id, 'AR_PUBLIC']
  }

  let(:create_class) {
    Object.const_get((subject.class.name.split('::').reverse.drop(1).reverse << 'Create').join('::'))
  }

  let(:minimal_item) {
    create_class.(*build_params(minimal_params))[model_param]
  }

  context 'valid' do

    let(:full_params) {
      minimal_params.tap do |x|
        x[:description] = 'Public access'
      end
    }

    it '-- with description' do
      item = minimal_item
      result = subject.class.(*build_params(full_params.merge(id: item.id)))
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[model_param]).to be_persisted
      expect(result[model_param].id).to eql item.id
      full_params.each do |key, value|
        expect(result[model_param][key]).to eq value
      end
    end

    let(:name_change) {
      Hash[:name, 'OPEN']
    }

    it '-- no name change' do
      item = minimal_item
      result = subject.class.(*build_params(name_change.merge(id: item.id)))
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[model_param]).to be_persisted
      minimal_params.each do |key, value|
        expect(result[model_param][key]).to eq value
      end
    end

    let(:only_description) {
      Hash[:description, full_params[:description]]
    }

    it '-- only description' do
      item = minimal_item
      result = subject.class.(*build_params(only_description.merge(id: item.id)))
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[model_param]).to be_persisted
      minimal_params.each do |key, value|
        expect(result[model_param][key]).to eq value
      end
      only_description.each do |key, value|
        expect(result[model_param][key]).to eq value
      end
    end

    let(:full_item) {
      create_class.(*build_params(full_params))[model_param]
    }

    let(:remove_description) {
      Hash[:description, nil]
    }

    it '-- remove description' do
      item = full_item
      result = subject.class.(*build_params(remove_description.merge(id: item.id)))
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[model_param]).to be_persisted
      full_params.merge(remove_description).each do |key, value|
        expect(result[model_param][key]).to eq value
      end
    end

  end

  context 'invalid' do

    let(:other_params) {
      Hash[:name, 'PRIVATE', :ext_id, 'AR_PRIVATE']
    }

    let(:other_item) {
      create_class.(*build_params(other_params))[model_param]
    }

    it '-- duplicate name' do
      minimal_item
      item = other_item
      result = subject.class.(*build_params(other_params.merge(name: minimal_params[:name], id: item.id)))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).to be_persisted
      expect(result['contract.update'].errors.messages).to eq name: ['must be unique']
      other_params.each do |key, value|
        expect(result[model_param][key]).to eq value
      end
    end

    let(:emtpy_description) {
      minimal_params.tap do |x|
        x[:description] = ''
      end
    }

    it '-- empty description' do
      item = minimal_item
      result = subject.class.(*build_params(emtpy_description.merge(id: item.id)))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).to be_persisted
      expect(result['contract.update'].errors.messages).to eq description: ['size cannot be less than 1']
    end

  end

end
