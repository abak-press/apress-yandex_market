require 'net/http'
require 'openssl'
require 'uri'
require 'oj'

module Apress
  module YandexMarket
    module Api
      # API клиент Яндекс.Маркета
      class Client
        TIMEOUT = 60
        HOST = 'api.content.market.yandex.ru'.freeze
        ACCEPT = '*/*'.freeze
        VERSION = 'v2'.freeze

        # Public: инициализация клиента
        #
        # auth_token - String, токен для доступа к API
        #
        # Returns an instance of Api::Client
        def initialize(auth_token)
          @auth_token = auth_token
        end

        # Public: выполняет GET-запрос и парсит ответ в формате JSON
        #
        # path   - String, ресурс API
        # params - Hash, дополнительные get-параметры запроса (default: {})
        #
        # Returns Hash
        def get(path, params = {})
          uri = api_uri(path)
          uri.query = URI.encode_www_form(params) unless params.empty?

          req = Net::HTTP::Get.new(uri)
          req['Host'] = HOST
          req['Accept'] = ACCEPT
          req['Authorization'] = @auth_token

          res = Net::HTTP.start(uri.hostname, uri.port, http_options) do |http|
            http.request(req)
          end

          if res['Content-Type'] && res['Content-Type'].start_with?('application/json')
            parse_response(res)
          else
            raise Api::Error.new(res.msg, res.code)
          end
        end

        private

        def api_uri(path)
          URI "https://#{HOST}/#{VERSION}/#{path}"
        end

        def parse_response(res)
          Oj.load(res.body, symbol_keys: true, mode: :compat).tap do |data|
            if data[:status] == 'ERROR'
              err = data[:errors].first

              raise Api::Error.new(err[:message], res.code)
            end

            raise Api::Error.new(res.msg, res.code) unless res.is_a? Net::HTTPOK
          end
        end

        def http_options
          {
            open_timeout: TIMEOUT,
            read_timeout: TIMEOUT,
            use_ssl: true
          }
        end
      end
    end
  end
end
