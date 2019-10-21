require 'workarea/testing/teaspoon'

Teaspoon.configure do |config|
  config.root = Workarea::Zipco::Engine.root
  Workarea::Teaspoon.apply(config)
end
