require 'active_record_spec_helper'

require 'teneo/data_model'

require 'awesome_print'

RSpec.describe Teneo::DataModel::Concept::Format::Operation::Update do
  let(:minimal_params) {
    Hash[:name, 'TIFF', :category, 'IMAGE', :mime_types, %w'image/tiff', :extensions, %w'tif']
  }

  let(:minimal_format) {
    (Teneo::DataModel::Concept::Format::Operation::Create.(params: minimal_params))[:model]
  }

  context 'valid' do

    let(:full_params) {
      minimal_params.tap do |x|
        x[:description] = 'Tagged Image File Format (TIFF)'
        x[:mime_types] = %w'image/tiff image/x-tiff image/tif image/x-tif application/tiff application/x-tiff application/tif application/x-tif'
        x[:puids] = %w'fmt/353 fmt/154 fmt/153 fmt/156 fmt/155 fmt/152 fmt/202 x-fmt/387 x-fmt/388 x-fmt/399'
        x[:extensions] = %w'tif TIF tiff tifx dng nef'
      end
    }

    it '-- with full description' do
      format = minimal_format
      result = subject.class.(params: full_params, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[:model]).to be_persisted
      expect(result[:model].id).to eql format.id
      full_params.each do |key, value|
        expect(result[:model][key]).to eq value
      end
    end

    let(:name_change) {
      Hash[:name, 'IMAGE_FORMAT']
    }

    it '-- no name change' do
      format = minimal_format
      result = subject.class.(params: name_change, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[:model]).to be_persisted
      minimal_params.each do |key, value|
        expect(result[:model][key]).to eq value
      end
    end

    let(:only_description) {
      Hash[:description, 'Some image format']
    }

    it '-- only description' do
      format = minimal_format
      result = subject.class.(params: only_description, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[:model]).to be_persisted
      minimal_params.each do |key, value|
        expect(result[:model][key]).to eq value
      end
      only_description.each do |key, value|
        expect(result[:model][key]).to eq value
      end
    end

    let(:full_format) {
      (Teneo::DataModel::Concept::Format::Operation::Create.(params: full_params))[:model]
    }

    let(:remove_description) {
      Hash[:description, nil]
    }

    it '-- remove description' do
      format = full_format
      result = subject.class.(params: remove_description, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[:model]).to be_persisted
      full_params.merge(remove_description).each do |key, value|
        expect(result[:model][key]).to eq value
      end
    end

    let(:remove_puids) {
      Hash[:puids, nil]
    }

    it '-- remove puids' do
      format = full_format
      result = subject.class.(params: remove_puids, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_success
      expect(result[:model]).to be_persisted
      full_params.merge(remove_puids).each do |key, value|
        expect(result[:model][key]).to eq value
      end
    end

  end

  context 'invalid' do

    let(:other_params) {
      Hash[:name, 'JPG', :category, 'IMAGE', :mime_types, %w'image/jpg', :extensions, %w'jpg']
    }

    let(:other_format) {
      (Teneo::DataModel::Concept::Format::Operation::Create.(params: other_params))[:model]
    }

    it '-- duplicate name' do
      minimal_format
      format = other_format
      result = subject.class.(params: other_params.merge(name: minimal_params[:name]), id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[:model]).to be_persisted
      expect(result['contract.default'].errors.messages).to eq name: ['must be unique']
      other_params.each do |key, value|
        expect(result[:model][key]).to eq value
      end
    end

    let(:wrong_category) {
      minimal_params.tap do |x|
        x[:category] = 'BAD'
      end
    }

    it '-- wrong category' do
      format = minimal_format
      result = subject.class.(params: wrong_category, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[:model]).to be_persisted
      expect(result['contract.default'].errors.messages).to eq category: ['must be one of: IMAGE, AUDIO, VIDEO, TEXT, TABULAR, PRESENTATION, ARCHIVE, EMAIL, OTHER']
    end

    let(:emtpy_description) {
      minimal_params.tap do |x|
        x[:description] = ''
      end
    }

    it '-- empty description' do
      format = minimal_format
      result = subject.class.(params: emtpy_description, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[:model]).to be_persisted
      expect(result['contract.default'].errors.messages).to eq description: ['size cannot be less than 1']
    end

    let(:no_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = nil
      end
    }

    it '-- no mimetypes' do
      format = minimal_format
      result = subject.class.(params: no_mime_types, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[:model]).to be_persisted
      expect(result['contract.default'].errors.messages).to eq mime_types: ['must be filled', 'size cannot be less than 1', 'must be an array of String']
    end

    let(:empty_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = []
      end
    }

    it '-- empty mimetypes' do
      format = minimal_format
      result = subject.class.(params: empty_mime_types, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[:model]).to be_persisted
      expect(result['contract.default'].errors.messages).to eq mime_types: ['must be filled', 'size cannot be less than 1', 'must be an array of String']
    end

    let(:wrong_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = :tiff
      end
    }

    it '-- wrong mimetypes' do
      format = minimal_format
      result = subject.class.(params: wrong_mime_types, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[:model]).to be_persisted
      expect(result['contract.default'].errors.messages).to eq mime_types: ['must be an array', 'size cannot be less than 1', 'must be an array of String']
    end

    let(:bad_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = [:tiff]
      end
    }

    it '-- bad mimetypes' do
      format = minimal_format
      result = subject.class.(params: bad_mime_types, id: format.id)
      # ap result['contract.default'].errors.messages
      expect(result).to be_failure
      expect(result[:model]).to be_persisted
      expect(result['contract.default'].errors.messages).to eq mime_types: ['must be an array of String']
    end

  end

end
