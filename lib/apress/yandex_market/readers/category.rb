require 'apress/yandex_market/readers/base'
require 'facets/string/squish'

module Apress
  module YandexMarket
    module Readers
      # Ридер категорий. Читает из API Яндекс.Маркета переданные категории и их подкатегории
      #
      # Examples
      #
      #   reader = Apress::YandexMarket::Readers::Category.new(region_id: 225,
      #                                                        token: 'qwerty',
      #                                                        categories: 'Авто; Дом и дача')
      #   # => #<Apress::YandexMarket::Readers::Category ...>
      #
      #   reader.each_row |category|
      #     puts category
      #   end
      #   # => {
      #          :id=>90402,
      #          :name=>"Авто",
      #          :fullName=>"Товары для авто- и мототехники",
      #          :link=>
      #            "https://market.yandex.ru/catalog/90402/list?hid=90402&onstock=1&pp=1001&clid=2326601&distr_type=7",
      #          :childCount=>12,
      #          :advertisingModel=>"HYBRID",
      #          :viewType=>"LIST"
      #        }
      #        {
      #          :id=>90403,
      #          ...
      #        }
      class Category < Base
        FIELDS = %w(PARENT).join(',').freeze

        class << self
          def allowed_options
            super + %i(categories)
          end
        end

        # Public: инициализация ридера
        #
        # options - Hash, параметры ридера
        #   :region_id  - идентификатор региона (необязательный)
        #   :token      - токен для доступа к API Яндекс.Маркета
        #   :categories - список категорий для загрузки моделей Яндекс.Маркета
        #
        # Returns an instance of Readers::Category
        def initialize(options)
          super
          @category_names = options.fetch(:categories).split(';').map(&:squish)
        end

        # Public: читаем категории из API и для каждой выполняем блок
        #
        # Returns nothing
        def each_row
          root_categories.each do |root_category|
            yield root_category
            page = 1

            loop do
              sleep(SLEEP_TIME)
              categories =
                with_rescue_api_errors do
                  client.
                    get(
                      "categories/#{root_category.fetch(:id)}/children",
                      geo_id: @region_id,
                      sort: 'BY_NAME'.freeze,
                      count: PAGE_SIZE,
                      page: page
                    ).
                    fetch(:categories)
                end

              categories.each { |category| yield category }
              break if categories.count < PAGE_SIZE
              page += 1
            end
          end
        end

        private

        def root_categories
          client.
            get('categories', geo_id: @region_id).
            fetch(:categories).
            select { |category| @category_names.include?(category.fetch(:name)) }
        end
      end
    end
  end
end
