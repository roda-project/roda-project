# frozen_string_literal: true

require_relative "lib/roda/project/version"

Gem::Specification.new do |spec|
  spec.name = "roda-project"
  spec.version = Roda::Project::VERSION
  spec.authors = ["Henrique F. Teixeira"]
  spec.email = ["hriqueft@gmail.com"]

  spec.summary = "A command-line interface (CLI) tool that helps you quickly scaffold new Roda web applications "
  spec.homepage = "https://github.com/roda-project"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/roda-project/roda-project"
  spec.metadata["changelog_uri"] = "https://github.com/roda-project/roda-project/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{bin,lib}/**/*"]
  spec.executables << "roda-project"
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "tty-file"
  spec.add_dependency "tty-reader"
  spec.add_dependency "pastel"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
