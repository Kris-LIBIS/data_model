require 'active_record_spec_helper'

require 'teneo/data_model'

require 'awesome_print'

RSpec.describe Teneo::DataModel::Concept::AccessRight::Operation::Index do
  let(:item_params) {
    [
        {name: 'PUBLIC', ext_id: 'AR_PUBLIC'},
        {name: 'PRIVATE', ext_id: 'AR_PRIVATE'},
        {name: 'PROTECTED', ext_id: 'AR_PROTECTED'},
        {name: 'OPEN', ext_id: 'AR_PUBLIC'},
    ]
  }

  before(:example) do
    item_params.each do |params|
      result = Teneo::DataModel::Concept::AccessRight::Operation::Create.(*build_params(params))
      expect(result).to be_success
    end
  end

  it 'all' do
    result = subject.class.()
    expect(result).to be_success
    expect(result[model_param].count).to eql 4
    item_params.each_with_index do |params, i|
      params.each do |key, value|
        expect(result[model_param][i][key]).to eql value
      end
    end
  end

  let(:filter_name) {{name: item_params[0][:name]}}

  it 'filter: name=PUBLIC' do
    result = subject.class.(filter: filter_name)
    expect(result).to be_success
    expect(result[model_param].count).to eql 1
    item_params[0, 1].each_with_index do |params, i|
      params.each do |key, value|
        expect(result[model_param][i][key]).to eql value
      end
    end
  end

  let(:filter_id) {{ext_id: item_params[0][:ext_id]}}

  it 'filter: ext_id=AR_PUBLIC' do
    result = subject.class.(filter: filter_id)
    expect(result).to be_success
    expect(result[model_param].count).to eql 2
    (item_params[0, 1] + item_params[3, 1]).each_with_index do |params, i|
      params.each do |key, value|
        expect(result[model_param][i][key]).to eql value
      end
    end
  end

  let(:filter_id_name) {{ext_id: item_params[0][:ext_id], name: item_params[3][:name]}}

  it 'filter: ext_id=AR_PUBLIC and name=OPEN' do
    result = subject.class.(filter: filter_id_name)
    expect(result).to be_success
    expect(result[model_param].count).to eql 1
    item_params[3, 1].each_with_index do |params, i|
      params.each do |key, value|
        expect(result[model_param][i][key]).to eql value
      end
    end
  end


  let(:filter_name_id) {{name: item_params[0][:name], ext_id: item_params[1][:ext_id]}}

  it 'filter: ext_id=AR_PRIVATE and name=PUBLIC' do
    result = subject.class.(filter: filter_name_id)
    expect(result).to be_success
    expect(result[model_param].count).to eql 0
  end

end
