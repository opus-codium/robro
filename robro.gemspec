require_relative 'lib/robro/version'

Gem::Specification.new do |spec|
  spec.name          = "robro"
  spec.version       = Robro::VERSION
  spec.authors       = ["Romuald Conty"]
  spec.email         = ["neomilium@gmail.com"]

  spec.summary       = %q{Robotized Browser}
  spec.description   = %q{Automate tasks that require a _real_ browser}
  spec.homepage      = "https://github.com/neomilium/robro"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}.git"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/Changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capybara"
  spec.add_dependency "capybara-screenshot"
  spec.add_dependency "selenium-webdriver"
  spec.add_dependency "thor"
  spec.add_dependency "tty-logger"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
