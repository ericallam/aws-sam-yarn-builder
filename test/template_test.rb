require "minitest/autorun"
require "aws_sam_yarn_builder"

class TemplateTest < Minitest::Test
  def test_serverless_transform
    template = AwsSamYarnBuilder::Template.extract_from_file!("./test/fixture_apps/sam-app/template.yml")

    assert_equal "AWS::Serverless-2016-10-31", template.transform
  end

  def test_function_resources
    template = AwsSamYarnBuilder::Template.extract_from_file!("./test/fixture_apps/sam-app/template.yml")

    functions = template.function_resources

    assert_equal 1, functions.size

    function = functions.first

    assert_equal "./src/hello-world", function.path
    assert_equal "HelloWorldFunction", function.name
  end
end
