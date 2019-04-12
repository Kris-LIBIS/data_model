RSpec.describe Teneo::DataModel::Format do

  describe 'create' do

    let(:minimal_params) {
      Hash[:name, 'TIFF', :category, 'IMAGE', :mime_types, %w'image/tiff', :extensions, %w'tif']
    }

    it 'with minimal data' do
      result = described_class.create(minimal_params)
      expect(result.persisted?).to be_truthy
      minimal_params.each do |key, value|
        expect(result[key]).to eq value
      end
      expect(result['description']).to be_nil
    end

    it 'as duplicate' do
      described_class.create(minimal_params)
      expect {described_class.create(minimal_params)}.to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique constraint/)
    end

    let(:full_params) {
      minimal_params.tap do |x|
        x[:description] = 'Tagged Image File Format (TIFF)'
        x[:mime_types] = %w'image/tiff image/x-tiff image/tif image/x-tif application/tiff application/x-tiff application/tif application/x-tif'
        x[:puids] = %w'fmt/353 fmt/154 fmt/153 fmt/156 fmt/155 fmt/152 fmt/202 x-fmt/387 x-fmt/388 x-fmt/399'
        x[:extensions] = %w'tif TIF tiff tifx dng nef'
      end
    }

    it 'with full data' do
      result = described_class.create(full_params)
      expect(result.persisted?).to be_truthy
      full_params.each do |key, value|
        expect(result[key]).to eq value
      end
    end

    let(:missing_name) {
      minimal_params.tap do |x|
        x.delete(:name)
      end
    }

    it 'with missing name' do
      expect {described_class.create(missing_name)}.to raise_error(ActiveRecord::NotNullViolation, /null value in column "name"/)
    end

    let(:wrong_category) {
      minimal_params.tap do |x|
        x[:category] = 'BAD'
      end
    }

    it 'with wrong category' do
      expect {described_class.create(wrong_category)}.to raise_error(ActiveRecord::StatementInvalid, /invalid input value for enum/)
    end

    let(:emtpy_description) {
      minimal_params.tap do |x|
        x[:description] = ''
      end
    }

    it 'with empty description' do
      # unfortunately not:
      # expect {described_class.create(emtpy_description)}.to raise_error
      result = described_class.create(emtpy_description)
      expect(result.description).to_not be_nil
      expect(result.description).to eql ''
    end

    let(:no_mime_types) {
      minimal_params.tap do |x|
        x.delete(:mime_types)
      end
    }

    it 'with no mime_types' do
      expect {described_class.create(no_mime_types)}.to raise_error(ActiveRecord::NotNullViolation, /null value in column "mime_types"/)
    end

    let(:empty_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = []
      end
    }

    it 'with empty mime_types' do
      # unfortunately not:
      # expect {described_class.create(empty_mime_types)}.to raise_error
      result = described_class.create(empty_mime_types)
      expect(result.persisted?).to be_truthy
      expect(result[:mime_types]).to be_a(Array)
      expect(result[:mime_types]).to be_empty
    end

    let(:wrong_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = :tiff
      end
    }

    it 'with wrong mimetypes' do
      # unfortunately not:
      # expect {described_class.create(empty_mime_types)}.to raise_error
      result = described_class.create(empty_mime_types)
      expect(result.persisted?).to be_truthy
    end

    let(:bad_mime_types) {
      minimal_params.tap do |x|
        x[:mime_types] = [:tiff]
      end
    }

    it 'with bad mimetypes' do
      # unfortunately not:
      # expect {described_class.create(bad_mime_types)}.to raise_error
      result = described_class.create(bad_mime_types)
      expect(result.persisted?).to be_truthy
    end


  end

  describe 'update' do

    let(:minimal_params) {
      Hash[:name, 'TIFF', :category, 'IMAGE', :mime_types, %w'image/tiff', :extensions, %w'tif']
    }

    let(:minimal_with_description) {
      minimal_params.tap do |x|
        x[:description] = 'Tagged Image File Format (TIFF)'
      end
    }

    let(:full_params) {
      minimal_with_description.tap do |x|
        x[:mime_types] = %w'image/tiff image/x-tiff image/tif image/x-tif application/tiff application/x-tiff application/tif application/x-tif'
        x[:puids] = %w'fmt/353 fmt/154 fmt/153 fmt/156 fmt/155 fmt/152 fmt/202 x-fmt/387 x-fmt/388 x-fmt/399'
        x[:extensions] = %w'tif TIF tiff tifx dng nef'
      end
    }

    it 'with full params' do
      result = described_class.create(minimal_params)
      expect(result.update(full_params)).to be_truthy
      expect {result.save}.not_to raise_error
      expect(result.persisted?).to be_truthy
      full_params.each do |key, value|
        expect(result[key]).to eq value
      end
    end

    let(:without_description) {
      full_params.tap do |x|
        x.delete(:description)
      end
    }

    it 'without description' do
      result = described_class.create(minimal_params.merge(description: full_params[:description]))
      expect(result.update(without_description)).to be_truthy
      expect {result.save}.not_to raise_error
      expect(result.persisted?).to be_truthy
      full_params.each do |key, value|
        expect(result[key]).to eq value
      end
    end

    let(:with_nil_description) {
      full_params.tap do |x|
        x[:description] = nil
      end
    }

    it 'with_nil description' do
      result = described_class.create(minimal_params.merge(description: full_params[:description]))
      expect(result.update(with_nil_description)).to be_truthy
      expect {result.save}.not_to raise_error
      expect(result.persisted?).to be_truthy
      with_nil_description.each do |key, value|
        expect(result[key]).to eq value
      end
    end

  end

end
