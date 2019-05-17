module AwsSamYarnBuilder
  class Build
    def initialize(options = {})
      self.options = options
    end

    def build!
      if options[:function]
        build_single_function!
      else
        build_full_template!
      end
    end

    def build_full_template!
      reset_build_dir!
      reset_staging_dir!

      local_dependencies = template.function_resources.map do |function|
        get_local_file_dependencies(function)
      end.flatten.uniq.compact

      local_dependencies.each do |d|
        d.pack destination_staging_dir
      end

      template.function_resources.each do |function|
        package = package_from_function(function)

        package.pack destination_staging_dir
        package.build function.name, destination_dir, destination_staging_dir
      end

      template.write_to_output(destination_dir, template_base_dir)

      FileUtils.rm_rf(destination_staging_dir)
    end

    def build_single_function!
      reset_build_dir!
      reset_staging_dir!

      function_resource = template.function_resource_by_logical_id(options[:function])

      if function_resource
        local_dependencies = get_local_file_dependencies(function_resource).flatten.uniq.compact

        local_dependencies.each do |d|
          d.pack destination_staging_dir
        end

        package = package_from_function(function_resource)

        package.pack destination_staging_dir
        package.build function_resource.name, destination_dir, destination_staging_dir

        FileUtils.rm_rf(destination_staging_dir)
      end
    end

    protected

    attr_accessor :options

    def get_local_file_dependencies(function)
      package = package_from_function(function)

      package.dependencies.select(&:local?)
    end

    def package_from_function(function)
      Package.extract_from_file! File.join(File.expand_path(File.join(template_base_dir, function.path)), "package.json")
    end

    def reset_staging_dir!
      FileUtils.rm_rf(destination_staging_dir)
      FileUtils.mkdir_p(destination_staging_dir)
    end

    def reset_build_dir!
      FileUtils.rm_rf(destination_dir)
      FileUtils.mkdir_p(destination_dir)
    end

    def destination_dir
      @destination_dir ||= File.join(File.expand_path(options[:destination]), "build")
    end

    def destination_staging_dir
      @destination_staging_dir ||= File.join(File.expand_path(options[:destination]), "tmp")
    end

    def template
      @template ||= Template.extract_from_file!(File.expand_path(options[:template_file]))
    end

    def template_base_dir
      File.dirname(File.expand_path(options[:template_file]))
    end
  end
end
