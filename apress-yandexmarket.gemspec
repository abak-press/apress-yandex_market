lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include? lib

require 'apress/yandex_market/version'

Gem::Specification.new do |gem|
  gem.name         = 'apress-yandex_market'
  gem.version      = Apress::YandexMarket::VERSION
  gem.authors      = ['Mikhail Nelaev']
  gem.email        = %w(spyderdfx@gmail.com)
  gem.summary      = 'Tools for synchronization with Yandex.Market'
  gem.homepage     = 'https://github.com/abak-press/apress-yandex_market'

  gem.files        = `git ls-files -z`.split("\x0")
  gem.test_files   = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_path = "lib"

  gem.add_runtime_dependency 'oj'
  gem.add_runtime_dependency 'facets'

  gem.add_development_dependency 'bundler', '~> 1.6'
  gem.add_development_dependency 'rake', '< 11.0'  # https://github.com/lsegal/yard/issues/947

  # test
  gem.add_development_dependency 'rspec', '>= 3.5'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'rspec-collection_matchers'
  gem.add_development_dependency 'webmock', '< 2.3'
  gem.add_development_dependency 'vcr'

  # test coverage tools
  gem.add_development_dependency 'simplecov', '~> 0.10.0'

  # debug
  gem.add_development_dependency 'pry-byebug'
end
