$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "resourcify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "resourcify"
  s.version     = Resourcify::VERSION
  s.authors     = ["Stephen Baidu"]
  s.email       = ["stephenbaidu@gmail.com"]
  s.homepage    = "https://github.com/stephenbaidu/resourcify"
  s.license     = 'MIT'
  s.summary     = "Resourcify rails controllers and models"
  s.description = "Resourcify rails controllers and models"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency "pundit"

  s.add_development_dependency "sqlite3"
end
