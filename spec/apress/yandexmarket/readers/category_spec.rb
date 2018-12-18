require 'spec_helper'

describe Apress::YandexMarket::Readers::Category do
  let(:categories) { 'Авто; Красота' }
  let(:reader) { described_class.new(token: 'secret_token', categories: categories) }

  describe '.allowed_options' do
    it { expect(described_class.allowed_options).to eq %i(token region_id categories) }
  end

  describe '#each_row' do
    let(:rows) { [] }

    context 'when no errors' do
      before do
        VCR.use_cassette 'read_two_categories' do
          reader.each_row { |row| rows << row }
        end
      end

      it 'reads specified categories and their subcategories' do
        expect(rows).to have(157).items
        expect(rows.map { |row| row[:name] }).to include('Авто', 'Красота') # корневые категории
        expect(rows.map { |row| row[:name] }).
          to include('Авто', 'Запчасти', 'Фильтры', 'Воздушные фильтры') # поддерево от корня до листа
      end
    end

    context 'when page error' do
      before do
        allow(reader.client).to receive(:get).and_call_original
        allow(reader.client).to receive(:get).with('categories/90509/children', anything).
          and_raise(Apress::YandexMarket::Api::PageError)

        VCR.use_cassette 'read_two_categories_with_page_error' do
          reader.each_row { |row| rows << row }
        end
      end

      it 'reads specified categories and their subcategories' do
        expect(rows).to have(187).items
        expect(rows.map { |row| row[:name] }).to include('Авто', 'Красота')
      end
    end
  end
end
