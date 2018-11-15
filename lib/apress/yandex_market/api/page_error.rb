module Apress
  module YandexMarket
    module Api
      class PageError < StandardError
        MSG = "Parameter 'page' has invalid value. Parameter does not fit range constraint".freeze
      end
    end
  end
end
