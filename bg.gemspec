$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bg/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bg"
  s.version     = Bg::VERSION
  s.authors     = ["Nathan Hopkins"]
  s.email       = ["natehop@gmail.com"]
  s.homepage    = "https://github.com/hopsoft/bg"
  s.summary     = "Summary of Bg."
  s.description = "Description of Bg."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"
  s.add_dependency "concurrent-ruby", "~> 1.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rubocop"
end
