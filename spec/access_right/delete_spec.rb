# frozen_string_literal: true
require 'active_record_spec_helper'

require 'teneo/data_model'

require 'awesome_print'

RSpec.describe Teneo::DataModel::Concept::AccessRight::Operation::Delete do

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

    it '-- delete existing item' do
      item = minimal_item
      result = subject.class.(*build_params(id: item.id))
      expect(result).to be_success
      expect(result[model_param]).not_to be_persisted
      expect(result[model_param].id).to eql item.id
      minimal_params.each do |key, value|
        expect(result[model_param][key]).to eq value
      end
    end

  end

  context 'invalid' do

    it '-- delete non-existing item' do
      result = subject.class.(*build_params(id: 0))
      expect(result).to be_failure
      expect(result[model_param]).to be_nil
    end

  end

end
