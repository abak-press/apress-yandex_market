require 'spec_helper'

describe Apress::YandexMarket::Api::Client do
  let(:client) { described_class.new 'some_secret_token' }

  describe '#get' do
    context 'get root categores' do
      subject { client.get('categories', geo_id: 225, count: 30) }

      it do
        VCR.use_cassette 'get_root_categories' do
          expect(subject).to be_a Hash
          expect(subject).to include(:categories, :context, :status)
          expect(subject[:status]).to eq 'OK'
          expect(subject[:categories]).to have(18).items
        end
      end
    end

    context 'when error' do
      subject { client.get('categories/999999999', geo_id: 225) }

      it do
        VCR.use_cassette 'get_category_with_invalid_id' do
          expect { subject }.to raise_error(Apress::YandexMarket::Api::Error, '404 - Category 999999999 not found')
        end
      end
    end

    context 'when error with html body' do
      let(:error_body) do
        '<html><body><h1>502 Bad Gateway</h1>The server returned an invalid or incomplete response.</body></html>'
      end

      subject { client.get('example') }

      before do
        stub_request(:get, 'https://api.content.market.yandex.ru/v2/example').to_return(status: 502, body: error_body)
      end

      it do
        expect { VCR.turned_off { subject } }.to raise_error(Apress::YandexMarket::Api::Error, '502 - ')
      end
    end
  end
end
