require "yaml"

module AwsSamYarnBuilder
  class Template
    String.class_eval do
      def indent(count, char = " ")
        gsub(/([^\n]*)(\n|$)/) do |match|
          last_iteration = ($1 == "" && $2 == "")
          line = ""
          line << (char * count) unless last_iteration
          line << $1
          line << $2
          line
        end
      end
    end

    class FunctionResource
      def initialize(name, properties = {})
        self.name = name
        self.properties = properties
      end

      def path
        properties["CodeUri"]
      end

      attr_reader :name

      protected

      attr_accessor :properties
      attr_writer :name
    end

    def self.extract_from_file!(file_path)
      new file_path, File.read(file_path)
    end

    def initialize(path, contents)
      self.path = path
      self.contents = contents
    end

    def write_to_output(output, source_directory, unified = false)
      File.open(File.join(output, "template.yaml"), "w+") do |file|
        file << transformed_contents(source_directory, unified)
      end
    end

    def transform
      document["Transform"]
    end

    def function_resources
      @function_resources ||= raw_function_resources.map { |name, options| FunctionResource.new(name, options["Properties"]) }
    end

    def function_resource_by_logical_id(logical_id)
      raw_function_resource = raw_function_resources.detect { |name, options| name == logical_id }

      FunctionResource.new(raw_function_resource.first, raw_function_resource.last["Properties"])
    end

    protected

    attr_accessor :contents, :path

    def document
      @document ||= YAML.load(contents)
    end

    def transformed_contents(source_directory, unified)
      contents_with_transformed_step_function_definitions(contents_with_transformed_function_paths(contents, unified), source_directory)
    end

    def contents_with_transformed_step_function_definitions(c, source_directory)
      c.gsub(/^(\s*)DefinitionUri:\s*(.*)/) do |_|
        "#{$1}DefinitionString: !Sub |\n#{resolve_step_function_definition_string($2, source_directory).indent($1.length + 2)}"
      end
    end

    def resolve_step_function_definition_string(definition_uri, source_directory)
      File.read(File.expand_path(File.join(source_directory, definition_uri)))
    end

    def contents_with_transformed_function_paths(c, unified)
      if unified
        c.gsub(/CodeUri:\s*(.*)/) do |_|
          "CodeUri: ./UnifiedPackage"
        end
      else
        c.gsub(/CodeUri:\s*(.*)/) do |_|
          "CodeUri: ./#{find_function_name_for_code_uri($1)}"
        end
      end
    end

    def find_function_name_for_code_uri(code_uri)
      raw_function_resources.detect { |name, options| options["Properties"]["CodeUri"] == code_uri }.first
    end

    def raw_resources
      document["Resources"]
    end

    def raw_function_resources
      raw_resources.select { |name, options| options["Type"] == "AWS::Serverless::Function" }
    end
  end
end
