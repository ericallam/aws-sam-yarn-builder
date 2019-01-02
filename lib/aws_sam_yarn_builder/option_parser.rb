require "slop"

module AwsSamYarnBuilder
  module OptionParser
    def self.parse!
      Slop.parse do |o|
        o.string "-d", "--destination", "path to use for the output of the build process", default: "./.aws-sam/build"
        o.string "-t", "--template-file", "path to the SAM template file", default: "./template.yml"

        o.on "--help" do
          puts o
          exit
        end
      end
    end
  end
end
