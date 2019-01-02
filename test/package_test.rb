require "minitest/autorun"
require "aws_sam_yarn_builder"

class PackageTest < Minitest::Test
  def test_extracting_from_file
    package = AwsSamYarnBuilder::Package.extract_from_file!("./test/fixture_apps/sam-app/src/hello-world/package.json")

    assert_equal "hello_world", package.name
    assert_equal "1.0.0", package.version

    first_dependency = package.dependencies.first

    assert first_dependency.local?
  end
end
