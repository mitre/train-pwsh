# frozen_string_literal: true

require_relative "lib/train-pwsh/version"

Gem::Specification.new do |spec|
  spec.name = "train-pwsh"
  spec.version = Train::Pwsh::VERSION
  spec.authors = ["Sujay Kandwal"]
  spec.email = ["skandwal@mitre.org"]
  spec.files = Dir['lib/**/*.rb'] + Dir['bin/*']+ ["README.md", "LICENSE.md", "NOTICE.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md"]
  spec.summary = "Enabling continuous Powershell connection over Inspec."
  spec.description = "Enabling continuous Powershell connection over Inspec."
  spec.homepage = "https://rubygems.org/gems/train-pwsh"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mitre/train-pwsh/"
  spec.metadata["changelog_uri"] = spec.metadata['source_code_uri'] + "blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "train", "~> 3.10"
  spec.add_dependency "ruby-pwsh"
  #Add powershell dependency
  #spec.add_dependency "pwsh" , "~> 0.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
