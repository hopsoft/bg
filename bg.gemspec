require_relative "lib/bg/version"

Gem::Specification.new do |gem|
  gem.name        = "bg"
  gem.license     = "MIT"
  gem.version     = Bg::VERSION
  gem.authors     = ["Nathan Hopkins"]
  gem.email       = ["natehop@gmail.com"]
  gem.homepage    = "https://github.com/hopsoft/bg"
  gem.summary     = ""

  gem.files       = Dir["lib/**/*.rb", "bin/*", "[A-Z]*"]
  gem.test_files  = Dir["test/**/*.rb"]

  gem.add_dependency "activerecord",    ">= 5.0"
  gem.add_dependency "activejob",       ">= 5.0"
  gem.add_dependency "globalid",        ">= 0.3"
  gem.add_dependency "concurrent-ruby", ">= 1.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "purdytest"
  gem.add_development_dependency "coveralls"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-nav"
  gem.add_development_dependency "pry-stack_explorer"
end
