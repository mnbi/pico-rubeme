# frozen_string_literal: true

require_relative "lib/pico_rubeme/version"

Gem::Specification.new do |spec|
  spec.name          = "pico-rubeme"
  spec.version       = PicoRubeme::VERSION
  spec.authors       = ["mnbi"]
  spec.email         = ["mnbi@users.noreply.github.com"]

  spec.summary       = "A Scheme core to implement Scheme."
  spec.description   = "A Scheme implementation inspired by pure-Lisp, which is intended to be used to implement Scheme."
  spec.homepage      = "https://github.com/mnbi/pico-rubeme"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mnbi/pico-rubeme"
  spec.metadata["changelog_uri"] = "https://github.com/mnbi/pico-rubeme/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
