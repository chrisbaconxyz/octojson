$:.push File.expand_path("../lib", __FILE__)

require "octojson/version"

Gem::Specification.new do |s|
  s.name        = "octojson"
  s.version     = ActiveRecord::Octojson::VERSION
  s.authors     = ["Chris Bacon"]
  s.email       = ["chris@crispybacon.io"]
  s.homepage      = "https://github.com/baconck/octojson"
  s.summary       = %q{Set a schema, defaults, and validations for your json attributes}
  s.description   = %q{Set a schema, defaults, and validations for your json attributes}
  
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activerecord", [">= 6.0.3.1"]
  s.add_dependency "pg", [">= 0.18.1"] 

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "pry"
  s.add_development_dependency "standalone_migrations"
end
