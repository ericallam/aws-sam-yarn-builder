
Gem::Specification.new do |spec|
  spec.name = "aws-sam-yarn-builder"
  spec.version = "0.1.0"
  spec.authors = ["Eric Allam"]
  spec.email = ["eric.allam@solvehq.com"]

  spec.summary = %q{A command line program to produce builds for aws-sam-cli for nodejs/yarn projects}
  spec.description = %q{A command line program to produce builds for aws-sam-cli for nodejs/yarn projects}
  spec.homepage = "https://github.com/solve-hq/aws-sam-yarn-builder"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
          "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.add_dependency "slop", "~> 4.6.0"
  spec.add_dependency "activesupport", "~> 5.2.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
