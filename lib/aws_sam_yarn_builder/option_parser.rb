require "slop"

module AwsSamYarnBuilder
  module OptionParser
    def self.parse!
      Slop.parse do |o|
        o.string "-d", "--destination", "path to use for the output of the build process", default: "./.aws-sam"
        o.string "-t", "--template-file", "path to the SAM template file", default: "./template.yml"
        o.string "-f", "--function", "The logical ID of a single function to build (optional)"

        o.on "--help" do
          puts o
          exit
        end
      end
    end
  end
end
