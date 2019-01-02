require "minitest/autorun"
require "aws_sam_yarn_builder"
require "yaml"
require "fixture_app_helpers"

class BuildTest < Minitest::Test
  include FixtureAppHelpers

  def test_a_single_function_with_one_local_dependency
    opts = {
      destination: fixture_app_path("sam-app/.aws-sam"),
      template_file: fixture_app_path("sam-app/template.yml"),
    }

    builder = AwsSamYarnBuilder::Build.new opts
    builder.build!

    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/template.yaml"))

    built_template = YAML.load(File.read(fixture_app_path("sam-app/.aws-sam/build/template.yaml")))

    hello_world_resource = built_template["Resources"]["HelloWorldFunction"]

    assert_equal "./HelloWorldFunction", hello_world_resource["Properties"]["CodeUri"]

    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction"))
    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/app.js"))
    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/package.json"))
    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/yarn.lock"))
    assert !File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/tests/unit/test-handler.js"))
    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/node_modules/local-file-dependency/package.json"))
  end

  def test_prebuild_hook
    opts = {
      destination: fixture_app_path("sam-app-build-hooks/.aws-sam"),
      template_file: fixture_app_path("sam-app-build-hooks/template.yml"),
    }

    builder = AwsSamYarnBuilder::Build.new opts
    builder.build!

    assert File.exist?(fixture_app_path("sam-app-build-hooks/.aws-sam/build/template.yaml"))

    built_template = YAML.load(File.read(fixture_app_path("sam-app-build-hooks/.aws-sam/build/template.yaml")))

    hello_world_resource = built_template["Resources"]["HelloWorldFunction"]

    assert_equal "./HelloWorldFunction", hello_world_resource["Properties"]["CodeUri"]

    assert File.exist?(fixture_app_path("sam-app-build-hooks/.aws-sam/build/HelloWorldFunction"))
    assert File.exist?(fixture_app_path("sam-app-build-hooks/.aws-sam/build/HelloWorldFunction/dist/app.js"))
    assert File.exist?(fixture_app_path("sam-app-build-hooks/.aws-sam/build/HelloWorldFunction/package.json"))
    assert File.exist?(fixture_app_path("sam-app-build-hooks/.aws-sam/build/HelloWorldFunction/yarn.lock"))
    assert !File.exist?(fixture_app_path("sam-app-build-hooks/.aws-sam/build/HelloWorldFunction/tests/unit/test-handler.js"))
    assert !File.exist?(fixture_app_path("sam-app-build-hooks/.aws-sam/build/HelloWorldFunction/src/app.ts"))
    assert File.exist?(fixture_app_path("sam-app-build-hooks/.aws-sam/build/HelloWorldFunction/node_modules/local-file-dependency/package.json"))
  end

  def test_building_twice
    opts = {
      destination: fixture_app_path("sam-app/.aws-sam"),
      template_file: fixture_app_path("sam-app/template.yml"),
    }

    builder = AwsSamYarnBuilder::Build.new opts
    builder.build!
    builder.build!

    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/template.yaml"))

    built_template = YAML.load(File.read(fixture_app_path("sam-app/.aws-sam/build/template.yaml")))

    hello_world_resource = built_template["Resources"]["HelloWorldFunction"]

    assert_equal "./HelloWorldFunction", hello_world_resource["Properties"]["CodeUri"]

    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction"))
    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/app.js"))
    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/package.json"))
    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/yarn.lock"))
    assert !File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/tests/unit/test-handler.js"))
    assert File.exist?(fixture_app_path("sam-app/.aws-sam/build/HelloWorldFunction/node_modules/local-file-dependency/package.json"))
  end

  def test_multiple_functions_with_one_local_dependency
    app_name = "sam-app-multiple-functions"

    opts = {
      destination: fixture_app_path("#{app_name}/.aws-sam"),
      template_file: fixture_app_path("#{app_name}/template.yml"),
    }

    builder = AwsSamYarnBuilder::Build.new opts
    builder.build!

    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/template.yaml"))

    built_template = YAML.load(File.read(fixture_app_path("#{app_name}/.aws-sam/build/template.yaml")))

    hello_world_resource = built_template["Resources"]["HelloWorldFunction"]

    assert_equal "./HelloWorldFunction", hello_world_resource["Properties"]["CodeUri"]

    foo_bar_resource = built_template["Resources"]["FooBarFunction"]
    assert_equal "./FooBarFunction", foo_bar_resource["Properties"]["CodeUri"]

    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/HelloWorldFunction"))
    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/HelloWorldFunction/app.js"))
    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/HelloWorldFunction/package.json"))
    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/HelloWorldFunction/yarn.lock"))
    assert !File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/HelloWorldFunction/tests/unit/test-handler.js"))
    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/HelloWorldFunction/node_modules/local-file-dependency/package.json"))

    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/FooBarFunction"))
    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/FooBarFunction/app.js"))
    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/FooBarFunction/package.json"))
    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/FooBarFunction/yarn.lock"))
    assert !File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/FooBarFunction/tests/unit/test-handler.js"))
    assert File.exist?(fixture_app_path("#{app_name}/.aws-sam/build/FooBarFunction/node_modules/local-file-dependency/package.json"))
  end
end
