$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "workarea/zipco/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "workarea-zipco"
  spec.version     = Workarea::Zipco::VERSION
  spec.authors     = ["Jeff Yucis"]
  spec.email       = ["jyucis@workarea.com"]
  spec.homepage    = ""
  spec.summary     = "Zip.co Payments for Workarea Ecommerce."
  spec.description = "Zip.com payment processor integration for Workarea Ecommerce."

  spec.files = `git ls-files`.split("\n")

  spec.add_dependency 'workarea', '>= 3.4.x'
end
