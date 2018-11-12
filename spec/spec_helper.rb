require 'rubygems'
require 'bundler/setup'

require 'simplecov'

SimpleCov.start do
  minimum_coverage 95
end

require 'apress/yandex_market'

require 'rspec'
require 'rspec/its'
require 'rspec/collection_matchers'

require 'pry-byebug'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures'
  config.hook_into :webmock
end
