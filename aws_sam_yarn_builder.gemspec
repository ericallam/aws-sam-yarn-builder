lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "aws_sam_yarn_builder/version"

Gem::Specification.new do |spec|
  spec.name = "aws_sam_yarn_builder"
  spec.version = AwsSamYarnBuilder::VERSION
  spec.authors = ["Eric Allam"]
  spec.email = ["eallam@icloud.com"]

  spec.summary = %q{A command line program to produce builds for aws-sam-cli for nodejs/yarn projects}
  spec.description = %q{A command line program to produce builds for aws-sam-cli for nodejs/yarn projects}
  spec.homepage = "https://github.com/ericallam/aws-sam-yarn-builder"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.add_dependency "slop", "~> 4.6.0"
  spec.add_dependency "activesupport", ">= 5.2", "< 6.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
