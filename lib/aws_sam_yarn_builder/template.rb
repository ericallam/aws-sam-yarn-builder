require "yaml"

module AwsSamYarnBuilder
  class Template
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

    def write_to_output(output)
      File.open(File.join(output, "template.yaml"), "w+") do |file|
        file << contents_with_transformed_function_paths
      end
    end

    def transform
      document["Transform"]
    end

    def function_resources
      @function_resources ||= raw_function_resources.map { |name, options| FunctionResource.new(name, options["Properties"]) }
    end

    protected

    attr_accessor :contents, :path

    def document
      @document ||= YAML.load(contents)
    end

    def contents_with_transformed_function_paths
      contents.gsub(/CodeUri:\s*(.*)/) do |_|
        "CodeUri: ./#{find_function_name_for_code_uri($1)}"
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
