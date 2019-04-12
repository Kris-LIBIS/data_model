# frozen_string_literal: true
require 'active_record_spec_helper'

require 'teneo/data_model'

require 'awesome_print'

RSpec.describe Teneo::DataModel::Concept::Format::Operation::Create do
  let(:minimal_params) {
    Hash[:name, 'TIFF', :category, 'IMAGE', :mime_types, %w'image/tiff', :extensions, %w'tif']
  }

  context 'valid' do

    it '-- minimal format' do
      result = subject.class.(*build_params(minimal_params))
      # ap result['contract.default'].errors.messages
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
        x[:description] = 'Tagged Image File Format (TIFF)'
        x[:mime_types] = %w'image/tiff image/x-tiff image/tif image/x-tif application/tiff application/x-tiff application/tif application/x-tif'
        x[:puids] = %w'fmt/353 fmt/154 fmt/153 fmt/156 fmt/155 fmt/152 fmt/202 x-fmt/387 x-fmt/388 x-fmt/399'
        x[:extensions] = %w'tif TIF tiff tifx dng nef'
      end
    }

    it '-- complete format' do
      result = subject.class.(*build_params(full_params))
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[model_param]).to be_persisted
      full_params.each do |key, value|
        expect(result[model_param].send(key)).to eq value
      end
    end

    let(:no_description) {
      full_params.tap do |x|
        x.delete(:description)
      end
    }

    it '-- no description' do
      result = subject.class.(*build_params(no_description))
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[model_param]).to be_persisted
      expect(result[model_param].description).to be_nil
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
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq name: ['must be filled', 'must be unique']
    end

    it '-- duplicate name' do
      subject.class.(*build_params(minimal_params))
      result = subject.class.(*build_params(minimal_params))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq name: ['must be unique']
    end

    let(:wrong_category) {
      minimal_params.tap do |x|
        x[:category] = 'BAD'
      end
    }

    it '-- wrong category' do
      result = subject.class.(*build_params(wrong_category))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq category: ['must be one of: IMAGE, AUDIO, VIDEO, TEXT, TABULAR, PRESENTATION, ARCHIVE, EMAIL, OTHER']
    end

    let(:emtpy_description) {
      minimal_params.tap do |x|
        x[:description] = ''
      end
    }

    it '-- empty description' do
      result = subject.class.(*build_params(emtpy_description))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq description: ['size cannot be less than 1']
    end

    let(:no_mime_types) {
      minimal_params.tap do |x|
        x.delete(:mime_types)
      end
    }

    it '-- no mimetypes' do
      result = subject.class.(*build_params(no_mime_types))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq mime_types: ['must be filled', 'size cannot be less than 1', 'must be an array of String']
    end

    let(:empty_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = []
      end
    }

    it '-- empty mimetypes' do
      result = subject.class.(*build_params(empty_mime_types))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq mime_types: ['must be filled', 'size cannot be less than 1', 'must be an array of String']
    end

    let(:wrong_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = :tiff
      end
    }

    it '-- wrong mimetypes' do
      result = subject.class.(*build_params(wrong_mime_types))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq mime_types: ['must be an array', 'size cannot be less than 1', 'must be an array of String']
    end

    let(:bad_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = [:tiff]
      end
    }

    it '-- bad mimetypes' do
      result = subject.class.(*build_params(bad_mime_types))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq mime_types: ['must be an array of String']
    end

    let(:empty_puids) {
      minimal_params.tap do |x|
        x[:puids] = []
      end
    }

    it '-- empty puids' do
      result = subject.class.(*build_params(empty_puids))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq puids: ['size cannot be less than 1', 'must be an array of String']
    end

    let(:no_extensions) {
      minimal_params.tap do |x|
        x.delete(:extensions)
      end
    }

    it '-- no extensions' do
      result = subject.class.(*build_params(no_extensions))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq extensions: ['must be filled', 'size cannot be less than 1', 'must be an array of String']
    end

    let(:empty_extensions) {
      minimal_params.tap do |x|
        x[:extensions] = []
      end
    }

    it '-- empty extensions' do
      result = subject.class.(*build_params(empty_extensions))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq extensions: ['must be filled', 'size cannot be less than 1', 'must be an array of String']
    end

    let(:wrong_extensions) {
      minimal_params.tap do |x|
        x[:extensions] = 123
      end
    }

    it '-- wrong extensions' do
      result = subject.class.(*build_params(wrong_extensions))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq extensions: ['must be an array', 'size cannot be less than 1', 'must be an array of String']
    end

    let(:bad_extensions) {
      minimal_params.tap do |x|
        x[:extensions] = [123]
      end
    }

    it '-- bad extensionss' do
      result = subject.class.(*build_params(bad_extensions))
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[model_param]).not_to be_persisted
      expect(result['contract.default'].errors.messages).to eq extensions: ['must be an array of String']
    end

  end

end
