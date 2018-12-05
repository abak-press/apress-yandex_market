module Apress
  module YandexMarket
    module Presenters
      class Model < Base
        self.attributes = [
          :id,
          :name,
          :link,
          :description,
          photo: [:url].freeze,
          photos: [:url].freeze,
          price: [:min].freeze,
          vendor: [:name].freeze,
          specification: [features: [:name, :value].freeze].freeze
        ].freeze
      end
    end
  end
end
