require "fileutils"

class Roda
  module Project
    class JeremyTemplateCreator < Generator
      include Helpers::Inflections

      def call
        repo_url = "https://github.com/jeremyevans/roda-sequel-stack"
        puts "* Downloading template with git...\n\n"

        success = system("git clone --depth 1 #{repo_url} #{@context.project_name}")
        abort("\nCould not download the template.") unless success

        git_dir = File.join(@context.project_name, ".git")
        if Dir.exist?(git_dir)
          FileUtils.rm_rf(git_dir)
          puts "\n* Cleaned up template git history.\n\n"
        end

        action_success_message("./#{@context.project_name}")

        setup_command = "cd #{@context.project_name} && rake setup[#{camelize(@context.project_name)}]"
        system(setup_command)

        action_success_message(setup_command, "run")
        puts "\nSetup is done! follow the link below to learn about this template:"
        puts "\n#{repo_url}"
      end
    end
  end
end
