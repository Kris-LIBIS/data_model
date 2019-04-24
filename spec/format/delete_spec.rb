# frozen_string_literal: true
require 'active_record_spec_helper'

require 'teneo/data_model'

require 'awesome_print'

RSpec.describe Teneo::DataModel::Concept::Format::Operation::Delete do
  let(:minimal_params) {
    Hash[:name, 'TIFF', :category, 'IMAGE', :mime_types, %w'image/tiff', :extensions, %w'tif']
  }

  let(:minimal_format) {
    Teneo::DataModel::Concept::Format::Operation::Create.(*build_params(minimal_params))[model_param]
  }

  context 'valid' do

    it '-- delete existing format' do
      format = minimal_format
      result = subject.class.(*build_params(id: format.id))
      expect(result).to be_success
      expect(result[model_param]).not_to be_persisted
      expect(result[model_param].id).to eql format.id
      minimal_params.each do |key, value|
        expect(result[model_param][key]).to eq value
      end
    end

  end

  context 'invalid' do

    it '-- delete non-existing format' do
      result = subject.class.(*build_params(id: 0))
      expect(result).to be_failure
      expect(result[model_param]).to be_nil
      # expect(result['exception']).to eql 'ActiveRecord::RecordNotFound'
    end

  end

end
