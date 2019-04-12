require 'active_record_spec_helper'

require 'teneo/data_model'

require 'awesome_print'

RSpec.describe Teneo::DataModel::Concept::Format::Operation::Show do
  let(:minimal_params) {
    Hash[:name, 'TIFF', :category, 'IMAGE', :mime_types, %w'image/tiff', :extensions, %w'tif']
  }

  let(:minimal_format) {
    (Teneo::DataModel::Concept::Format::Operation::Create.(params: minimal_params))[:model]
  }

  context 'valid' do

    it '-- get format' do
      format = minimal_format
      result = subject.class.(id: format.id)
      expect(result).to be_success
      expect(result[:model]).to be_persisted
      expect(result[:model].id).to eql format.id
      minimal_params.each do |key, value|
        expect(result[:model][key]).to eq value
      end
    end

  end

  context 'invalid' do

    it '-- wrong ID' do
      format = minimal_format
      result = subject.class.(id: format.id * 100)
      expect(result).to be_failure
      expect(result[:model]).to be_nil
      expect(result[:errors]).to include?('TBD')
    end

  end

end
