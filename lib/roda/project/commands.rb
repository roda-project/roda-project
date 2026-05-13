require "dry/cli"

module Roda
  module Project
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc "Print version"

        def call(*)
          puts Roda::Project::VERSION
        end
      end

      register "version", Version, aliases: ["v", "-v", "--version"]
    end
  end
end
