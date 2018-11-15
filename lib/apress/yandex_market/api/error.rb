module Apress
  module YandexMarket
    module Api
      class Error < StandardError
        attr_reader :code

        def initialize(msg, code = nil)
          @code = code.to_i

          message = code ? "#{code} - #{msg}" : msg

          raise PageError.new(message) if msg.start_with? Api::PageError::MSG

          super message.force_encoding('UTF-8')
        end
      end
    end
  end
end
