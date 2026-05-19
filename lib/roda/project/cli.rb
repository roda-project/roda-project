# frozen_string_literal: true

module Roda
  module Project
    class CLI
      def initialize
        @context = {
          project_name: 'project',
          rodauth: false,
          base: 1,
          database: true,
          database_type: 1,
        }
        @pastel = Pastel.new

        reader = TTY::Reader.new
        puts(@pastel.bright_black("[roda-project v#{Roda::Project::VERSION}]\n"))

        project_name = reader.read_line("Project name › ").chomp
        @context[:project_name] = (project_name == "")? @context[:project_name] : project_name
        @context[:base] = reader.read_line("(1) API (2) Fullstack › ").chomp
        @context[:database] = reader.read_line("Database? (Y/n) › ").chomp
        if @context[:database] != ""
        else
          @context[:database_type] = reader.read_line("(1) SQlite (2) PostgreSQL (3) MySQL › ")
          @context[:rodauth] = reader.read_line("Rodauth? (authentication) (Y/n) › ")
        end
      end

      def call
        puts @pastel.bright_black("\n[project: #{@context[:project_name]}]\n")
        puts "* creating base project"
        TTY::File.copy_directory(
          File.expand_path("../templates/files/base/scaffold", __dir__),
          @context[:project_name],
          context: @context,
        )

        puts "* adding database"
        tty_cp_r('database', 'db')
        tty_cp('database', 'app/config/providers/db/conn.rb')

        puts "* adding front-end"
        cp_r('front-end', 'app/views')
        tty_cp_r('front-end', 'app/assets')
        tty_cp('front-end', 'esbuild.js')
        tty_cp('front-end', 'package.json')

        puts "* adding rodauth"
        tty_cp_r('rodauth', 'app/models')
        tty_cp('rodauth', 'db/migrations/001_add_rodauth.rb')
        cp('rodauth', 'app/views/create-account.erb')

        puts "\nrun rake to see all available tasks\n\n"
      rescue TTY::Reader::InputInterrupt
        puts "\n\nGoodbye"
      end

      def tty_cp_r(type, path)
        TTY::File.copy_directory(
          File.expand_path("../templates/files/#{type}/#{path}", __dir__),
          "#{@context[:project_name]}/#{path}",
          context: @context,
        )
      end

      def cp_r(type, path)
        FileUtils.cp_r(
          File.expand_path("../templates/files/#{type}/#{path}", __dir__),
          "#{@context[:project_name]}/#{path}"
        )
      end

      def tty_cp(type, path)
        TTY::File.copy_file(
          File.expand_path("../templates/files/#{type}/#{path}", __dir__),
          "#{@context[:project_name]}/#{path}"
        )
      end

      def cp(type, path)
        File.write(
          "#{@context[:project_name]}/#{path}",
          File.read(File.expand_path("../templates/files/#{type}/#{path}", __dir__)),
        )
      end
    end
  end
end
