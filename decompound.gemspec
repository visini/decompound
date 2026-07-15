# frozen_string_literal: true

require_relative "lib/decompound/version"

Gem::Specification.new do |spec|
  spec.name = "decompound"
  spec.version = Decompound::VERSION
  spec.authors = ["Camillo Visini"]

  spec.summary = "German compound word splitter"
  spec.description = "A Ruby gem for splitting German compound words into their constituent parts"
  spec.homepage = "https://github.com/visini/decompound"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ data/vendor/ Gemfile .gitignore test/ .github/ .standard.yml])
    end
  end
  spec.files << "data/ngram_probs.json"
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # The runtime model is stored as JSON.
  spec.add_dependency "json", ">= 2.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
