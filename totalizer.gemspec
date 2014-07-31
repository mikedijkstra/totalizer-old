# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'totalizer/version'

Gem::Specification.new do |spec|
  spec.name          = "totalizer"
  spec.version       = Totalizer::VERSION
  spec.authors       = ["Michael Dijkstra"]
  spec.email         = ["micdijkstra@gmail.com"]
  spec.summary       = %q{Totalizer calculates the important metrics in your Rails app.}
  spec.description   = %q{Provides tools to Ruby on Rails developers to create calculations for acquisiton, activation, engagement, retention and churn.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "factory_girl_rails"
  spec.add_development_dependency "database_cleaner"
end
