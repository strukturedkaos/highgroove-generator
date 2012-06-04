# -*- encoding: utf-8 -*-
require File.expand_path('../lib/highgroove-generator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Aubrey Rhodes"]
  gem.email         = ["aubrey.c.rhodes@gmail.com"]
  gem.description   = %q{Tool to generate a rails project ready for development}
  gem.summary       = %q{Highgroove rails project generator}
  gem.homepage      = "http://github.com/highgroove/highgroove-generator"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "highgroove_generator"
  gem.require_paths = ["lib"]
  gem.version       = Highgroove::Generator::VERSION

  gem.add_dependency "rails", '>= 3.2.0'
  gem.add_dependency "thor"
  gem.add_dependency "heroku"
end
