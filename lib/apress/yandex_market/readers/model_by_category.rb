require 'apress/yandex_market/readers/base'
require 'apress/yandex_market/readers/category'
require 'apress/yandex_market/presenters'

module Apress
  module YandexMarket
    module Readers
      # Ридер моделей Яндекс.Маркета по категориям
      #
      # Examples
      #
      #   reader = Apress::YandexMarket::Readers::ModelByCategory.new(region_id: 225,
      #                                                               token: 'qwerty')
      #   # => #<Apress::YandexMarket::Readers::ModelByCategory ...>
      #
      #   reader.each_row |model|
      #     puts model
      #   end
      #   # => {
      #          :__line__=>1,
      #          :__column__=>1,
      #          :id=>217189255,
      #          :name=>"Caviale Крем для лица Витамин Е",
      #          :link=>"https://market.yandex.ru/product/217189255?hid=8476099&pp=929&clid=2326601&distr_type=7",
      #          :description=>"время нанесения: дневной/ночной, эффект: увлажнение",
      #          :photo=>{:url=>"https://avatars.mds.yandex.net/get-mpic/331398/img_id833813452766046986.jpeg/orig"},
      #          :photos=>[
      #            {:url=>"https://avatars.mds.yandex.net/get-mpic/331398/img_id833813452766046986.jpeg/orig"},
      #            {:url=>"https://avatars.mds.yandex.net/get-mpic/331398/img_id8176844263482482207.jpeg/orig"},
      #            {:url=>"https://avatars.mds.yandex.net/get-mpic/933699/img_id2264997491683174997.jpeg/orig"}
      #          ],
      #          :price=>{:min=>"68"},
      #          :vendor=>{:name=>"Caviale"},
      #          :specification=>[
      #            {
      #              :features=>[
      #                {:value=>"время нанесения: дневной/ночной"},
      #                {:value=>"эффект: увлажнение"}
      #              ]
      #            }
      #          ]
      #        }
      #        {
      #          :__line__=>2,
      #          :__column__=>1,
      #          :id=>217189256,
      #          ...
      #        }
      class ModelByCategory < Base
        FIELDS = %w(
          MODEL_CATEGORY
          MODEL_PHOTO
          MODEL_PHOTOS
          MODEL_PRICE
          MODEL_SPECIFICATION
          MODEL_VENDOR
        ).join(',').freeze

        class << self
          def allowed_options
            Readers::Category.allowed_options
          end
        end

        attr_reader :category_reader

        # Public: инициализация ридера
        #
        # options - Hash, параметры ридера
        #   :region_id  - идентификатор региона (необязательный)
        #   :token      - токен для доступа к API Яндекс.Маркета
        #
        # Returns an instance of Readers::ModelByCategory
        def initialize(options)
          super
          @category_reader = Readers::Category.new(options)
        end

        # Public: читаем товары из API и фильтруем необходимые поля для использования далее в препроцессоре Кирби
        #
        # Returns nothing
        def each_row
          presenter = Presenters::Model.new

          category_reader.each_row do |category|
            page = 1

            loop do
              sleep(SLEEP_TIME)
              models =
                with_rescue_api_errors do
                  client.
                    get(
                      "categories/#{category.fetch(:id)}/search",
                      geo_id: @region_id,
                      result_type: 'MODELS'.freeze,
                      sort: 'DATE'.freeze,
                      how: 'DESC'.freeze,
                      fields: FIELDS,
                      count: PAGE_SIZE,
                      page: page
                    ).
                    fetch(:items)
                end

              models.each do |model|
                next if category.fetch(:id) == model.fetch(:category).fetch(:id)
                yield presenter.expose(model)
              end

              break if models.size < PAGE_SIZE

              page += 1
            end
          end
        end
      end
    end
  end
end
