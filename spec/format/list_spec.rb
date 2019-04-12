require 'active_record_spec_helper'

require 'teneo/data_model'

require 'awesome_print'

RSpec.describe Teneo::DataModel::Concept::Format::Operation::Index do
  let(:formats) {
    [
        Hash[:name, 'TIFF', :category, 'IMAGE', :mime_types, %w'image/tiff', :extensions, %w'tif'],
    ]
  }

  context 'valid' do
  end

  context 'invalid' do
  end

end
