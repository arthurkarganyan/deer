require_relative 'lib/deer/version'

Gem::Specification.new do |spec|
  spec.name          = "deer"
  spec.version       = Deer::VERSION
  spec.authors       = ["Arthur Karganyan"]
  spec.email         = ["arthur.karganyan@gmail.com"]

  spec.summary       = "Minimalist rack-framework"
  spec.description   = "Minimalist rack-framework"
  spec.homepage      = "https://github.com/arthurkarganyan/deer"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/arthurkarganyan/deer"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
