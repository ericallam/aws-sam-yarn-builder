module AwsSamYarnBuilder
  class Package
    class Dependency
      def initialize(parent, name, version)
        self.parent = parent
        self.name = name
        self.version = version
      end

      def local?
        version.start_with? "file:"
      end

      def pack(output)
        Package.extract_from_file!(File.join(local_path, "package.json")).pack(output)
      end

      def ==(o)
        o.class == self.class && o.name == name
      end

      def hash
        name.hash
      end

      alias_method :eql?, :==

      attr_reader :name, :version

      protected

      attr_writer :version, :name
      attr_accessor :parent

      def local_path
        File.expand_path(File.join(File.dirname(parent.path), version.gsub(/^file:/, "")))
      end
    end

    def self.extract_from_file!(file_path)
      new file_path, JSON.parse(File.read(file_path))
    end

    def initialize(path, contents)
      self.path = path
      self.contents = contents.with_indifferent_access
    end

    def name
      contents[:name]
    end

    def version
      contents[:version]
    end

    def dependencies
      @dependencies ||= contents[:dependencies].map { |name, version| Dependency.new(self, name, version) }
    end

    def dev_dependencies
      @dev_dependencies ||= contents[:devDependencies].map { |name, version| Dependency.new(self, name, version) }
    end

    def pack(output)
      change_to_directory do
        execute_command("yarn pack")
      end

      FileUtils.mv packaged_tarball_path, output

      Dir.chdir output do
        execute_command("tar zxvf #{packed_tarball_name}")

        FileUtils.mkdir_p name
        File.rename "package", name

        FileUtils.rm packed_tarball_name
      end

      package_json_path = File.join(output, name, "package.json")

      File.open(package_json_path, "w+") do |file|
        file << JSON.pretty_generate(overrite_local_dependencies)
      end
    end

    def build(output_name, output, tmp_directory)
      tmp_package_path = File.join(tmp_directory, name)

      yarn_lock_path = File.join(base_path, "yarn.lock")

      FileUtils.cp yarn_lock_path, tmp_package_path

      Dir.chdir tmp_package_path do
        puts "Yarn Installing for #{name}"

        execute_command("yarn install --ignore-scripts --production --pure-lockfile")
      end

      deploy_package_path = File.join(output, output_name)

      FileUtils.rm_rf deploy_package_path
      FileUtils.mv tmp_package_path, deploy_package_path

      package_json_path = File.join(deploy_package_path, "package.json")

      File.open(package_json_path, "w+") do |file|
        file << JSON.pretty_generate(contents)
      end
    end

    attr_reader :path

    protected

    attr_accessor :contents
    attr_writer :path

    def overrite_local_dependencies
      result = Marshal.load(Marshal.dump(contents))

      result[:dependencies] = contents[:dependencies].inject({}) do |deps, (name, version)|
        if version.start_with?("file:")
          deps[name] = "file:../#{name}"
        else
          deps[name] = version
        end

        deps
      end

      result[:devDependencies] = contents[:devDependencies].inject({}) do |deps, (name, version)|
        if version.start_with?("file:")
          deps[name] = "file:../#{name}"
        else
          deps[name] = version
        end

        deps
      end

      result
    end

    def change_to_directory(&block)
      Dir.chdir base_path, &block
    end

    def base_path
      File.dirname(path)
    end

    def packaged_tarball_path
      File.join(base_path, packed_tarball_name)
    end

    def packed_tarball_name
      packed_name + ".tgz"
    end

    def packed_name
      [name.gsub(/\//, "-").gsub(/@/, ""), "v#{version}"].join("-")
    end

    def execute_command(command)
      system command
    end
  end
end
