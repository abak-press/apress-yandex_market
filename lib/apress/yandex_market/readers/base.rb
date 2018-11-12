require 'apress/yandex_market/api'

module Apress
  module YandexMarket
    module Readers
      # Базовый класс ридеров
      class Base
        DEFAULT_REGION_ID = 225
        PAGE_SIZE = 30

        SLEEP_TIME = 0.5 # no more than 2 rpm

        RETRY_ATTEMPTS = 5
        RETRY_CODES = [500, 502, 503, 504].freeze

        attr_reader :client

        class << self
          def allowed_options
            %i(token region_id)
          end
        end

        # Public: инициализация ридера
        #
        # options - Hash, параметры ридера
        #   :region_id - идентификатор региона (необязательный)
        #   :token     - токен для доступа к API Яндекс.Маркета
        #
        # Returns an instance of Readers::Base
        def initialize(options)
          @region_id = options.fetch(:region_id, DEFAULT_REGION_ID)
          @client = Api::Client.new(options.fetch(:token))
        end

        private

        def with_rescue_api_errors(attempts = RETRY_ATTEMPTS)
          yield
        rescue Api::PageError
          []
        rescue Api::Error, Timeout::Error => err
          raise if err.is_a?(Api::Error) && !RETRY_CODES.include?(err.code)

          (attempts -= 1) > 0 ? retry : raise
        end
      end
    end
  end
end
