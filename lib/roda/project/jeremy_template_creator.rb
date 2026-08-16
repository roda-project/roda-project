require 'fileutils'

class Roda
  module Project
    class JeremyTemplateCreator < Generator
      def call
        generate_from_template(
          "https://github.com/jeremyevans/roda-sequel-stack",
          @context.project_name
        )
      end

      def generate_from_template(repo_url, target_dir)
        puts "* Downloading template with git...\n\n"

        # --depth 1 performs a shallow clone (fetches only the latest commit).
        # This makes the download significantly faster for templates.
        clone_command = "git clone --depth 1 #{repo_url} #{target_dir}"

        # Execute the shell command
        success = system(clone_command)
        abort("Error: Could not download the template.") unless success

        # Remove the .git directory so it becomes a fresh, untracked project
        git_dir = File.join(target_dir, '.git')
        if Dir.exist?(git_dir)
          FileUtils.rm_rf(git_dir)
          puts "\n* Cleaned up template git history.\n\n"
        end

        action_success_message("./#{target_dir}")
      end
    end
  end
end

