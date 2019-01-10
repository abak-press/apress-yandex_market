require 'apress/yandex_market/api'

module Apress
  module YandexMarket
    module Readers
      # Базовый класс ридеров
      class Base
        DEFAULT_REGION_ID = 225 # Россия
        PAGE_SIZE = 30 # максимум сущностей на одной странице в API Яндекс.Маркета

        SLEEP_TIME = 0.5 # no more than 2 rps

        RETRY_ATTEMPTS_SLEEP_TIME = [60, 60, 30, 15, 1].freeze
        RETRY_ATTEMPTS = RETRY_ATTEMPTS_SLEEP_TIME.size
        RETRY_CODES = [401, 403, 404, 500, 502, 503, 504].freeze

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

        def with_rescue_temporary_errors(attempts = RETRY_ATTEMPTS)
          yield
        rescue Api::Error, Timeout::Error => err
          raise if err.is_a?(Api::Error) && !RETRY_CODES.include?(err.code)

          if (attempts -= 1) > 0
            sleep RETRY_ATTEMPTS_SLEEP_TIME[attempts]
            retry
          else
            raise
          end
        end
      end
    end
  end
end
