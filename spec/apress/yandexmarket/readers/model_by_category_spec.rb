require 'spec_helper'

describe Apress::YandexMarket::Readers::ModelByCategory do
  let(:categories) { 'Красота' } # id: 90509
  let(:reader) { described_class.new(token: 'secret_token', categories: categories) }

  describe '.allowed_options' do
    it { expect(described_class.allowed_options).to eq %i(token region_id categories) }
  end

  describe '#each_row' do
    let(:rows) { [] }

    before do
      allow(reader.category_reader.client).to receive(:get).and_call_original
      allow(reader.category_reader.client).to receive(:get).with('categories/90509/children', anything).
        and_return(categories: [{id: 8_476_099, childCount: 0}])

      VCR.use_cassette 'read_models_from_category' do
        reader.each_row { |row| rows << row }
      end
    end

    it 'reads specified categories and their subcategories' do
      expect(rows).to have(1958).items
    end
  end
end
