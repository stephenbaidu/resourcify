$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "resourcify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "resourcify"
  s.version     = Resourcify::VERSION
  s.authors     = ["Stephen Baidu"]
  s.email       = ["stephen@axoninfosystems.com"]
  s.homepage    = "http://www.baidus.net"
  s.summary     = "Resourcify gem"
  s.description = "Resourcify gem"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
end
