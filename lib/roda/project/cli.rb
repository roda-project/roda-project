# frozen_string_literal: true

module Roda
  module Project
    class CLI
      include Helpers::Template
      include Helpers::Input

      def initialize
        @context = Context.new
        @pastel = Pastel.new

        puts(@pastel.bright_black("[roda-project v#{Roda::Project::VERSION}]\n"))

        @context.project_name = read_line("Project name › ", 'project')
        @context.base = read_line("(1) API (2) Fullstack › ", Roda::Project::API).to_i
        @context.database = read_line("Database? (Y/n) › ", true)
        if @context.database?
          @context.database_type = read_line("(1) SQlite (2) PostgreSQL (3) MySQL › ", Roda::Project::SQLite).to_i
          @context.rodauth = read_line("Rodauth? (authentication) (Y/n) › ", true)
        end
      rescue TTY::Reader::InputInterrupt
        puts "\n\nGoodbye"
      end

      def call
        puts @pastel.bright_black("\n[project: #{@context.project_name}]\n")
        puts "* creating base project"
        TTY::File.copy_directory(
          File.expand_path("../templates/base/scaffold", __dir__),
          @context.project_name,
          context: @context,
        )

        if @context.fullstack?
          puts "* adding front-end"
          tty_cp_r('front-end', 'app/assets')
          tty_cp('front-end', 'esbuild.js')
          tty_cp('front-end', 'package.json')
          cp_r('front-end', 'app/views')
        end

        if @context.database?
          puts "* adding database"
          tty_cp_r('database', 'db')
          tty_cp('database', 'app/config/providers/db/conn.rb')

          if @context.rodauth?
            puts "* adding rodauth"
            tty_cp_r('rodauth', 'app/models')
            tty_cp('rodauth', 'db/migrations/001_add_rodauth.rb')
            if @context.fullstack?
              cp('rodauth', 'app/views/create-account.erb')
            end
          end
        end

        puts "\nrun rake to see all available tasks\n\n"
      end
    end
  end
end
