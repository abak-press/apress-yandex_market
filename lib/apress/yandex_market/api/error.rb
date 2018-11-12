module Apress
  module YandexMarket
    module Api
      class Error < StandardError
        PAGE_ERROR_MSG = "Parameter 'page' has invalid value. Parameter does not fit range constraint".freeze

        attr_reader :code

        def initialize(msg, code = nil)
          @code = code.to_i

          message = code ? "#{code} - #{msg}" : msg

          raise PageError.new(message) if msg.start_with? PAGE_ERROR_MSG

          super message.force_encoding('UTF-8')
        end
      end
    end
  end
end
