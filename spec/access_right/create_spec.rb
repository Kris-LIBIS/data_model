# frozen_string_literal: true
require 'active_record_spec_helper'

require 'teneo/data_model'

require 'awesome_print'

RSpec.describe Teneo::DataModel::Concept::AccessRight::Operation::Create do
  let(:minimal_params) {
    Hash[:name, 'PUBLIC', :ext_id, 'AR_PUBLIC']
  }

  context 'valid' do

    it '-- minimal' do
      result = subject.class.(*build_params(minimal_params))
      # ap result['contract.create'].errors.messages
      expect(result).to be_success
      # ap result
      expect(result[model_param]).to be_persisted
      minimal_params.each do |key, value|
        expect(result[model_param].send(key)).to eq value
      end
      expect(result[model_param].description).to be_nil
      # ap result[model_param].inspect
    end

    let(:full_params) {
      minimal_params.tap do |x|
        x[:description] = 'Public access'
      end
    }

    it '-- complete' do
      result = subject.class.(*build_params(full_params))
      # ap result['contract.create'].errors.messages
      expect(result).to be_success
      expect(result[model_param]).to be_persisted
      full_params.each do |key, value|
        expect(result[model_param].send(key)).to eq value
      end
    end

  end

  context 'invalid' do

    let(:missing_name) {
      minimal_params.tap do |x|
        x.delete(:name)
      end
    }

    it '-- missing name' do
      result = subject.class.(*build_params(missing_name))
      # ap result['contract.create'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.create'].errors.messages).to eq name: ['must be filled', 'must be unique']
    end

    it '-- duplicate name' do
      subject.class.(*build_params(minimal_params))
      result = subject.class.(*build_params(minimal_params))
      # ap result['contract.create'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.create'].errors.messages).to eq name: ['must be unique']
    end

    let(:emtpy_description) {
      minimal_params.tap do |x|
        x[:description] = ''
      end
    }

    it '-- empty description' do
      result = subject.class.(*build_params(emtpy_description))
      # ap result['contract.create'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.create'].errors.messages).to eq description: ['size cannot be less than 1']
    end

  end

end
