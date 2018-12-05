module Apress
  module YandexMarket
    module Presenters
      class Base
        class << self
          attr_accessor :attributes

          attributes = []
        end

        def initialize
          @counter = 0
        end

        def expose(row)
          record = {
            __line__: @counter += 1,
            __column__: 1
          }

          record.merge! filter(row)

          record
        end

        private

        def filter(row, attrs = self.class.attributes)
          attrs.each_with_object({}) do |key, result|
            if key.is_a? Hash
              key.each do |hash_key, hash_attrs|
                next unless row.key? hash_key

                result[hash_key] =
                  if row[hash_key].is_a? Array
                    row[hash_key].map { |item| filter(item, hash_attrs) }
                  else
                    filter(row[hash_key], hash_attrs)
                  end
              end
            elsif row.key? key
              result[key] = row[key]
            end
          end
        end
      end
    end
  end
end
