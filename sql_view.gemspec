require_relative "lib/sql_view/version"

Gem::Specification.new do |spec|
  spec.name        = "sql_view"
  spec.version     = SqlView::VERSION
  spec.authors     = ["Igor Kasyanchuk"]
  spec.email       = ["igorkasyanchuk@gmail.com"]
  spec.homepage    = "https://github.com/igorkasyanchuk/sql_view"
  spec.summary     = "Simple way to create and interact with your SQL views using ActiveRecord."
  spec.description = "Simple way to create and interact with your SQL views using ActiveRecord."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails"
  spec.add_dependency "scenic"

  spec.add_development_dependency "pg"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "wrapped_print"
end
