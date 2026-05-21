# frozen_string_literal: true

module Roda
  module Project
    class CLI
      include Helpers::Template
      include Helpers::Input

      def initialize(context: Context.new, pastel: Pastel.new, dir: nil)
        @context = context
        @pastel = pastel
        @dir = dir
      end

      def call
        puts @pastel.bright_black("[roda-project v#{Roda::Project::VERSION}]\n")

        @context.project_name = read_line("Project name › ", "project")
        @context.base = read_line("(#{fullstack_id}) Fullstack (#{api_id}) API › ", fullstack_id).to_i
        @context.database = read_line("Database? (Y/n) › ", true)
        if @context.database?
          @context.database_type = read_line(
            "(#{sqlite_id}) SQlite (#{postgresql_id}) PostgreSQL (#{mysql_id}) MySQL › ",
            sqlite_id
          ).to_i
          @context.rodauth = read_line("Rodauth? (authentication) (Y/n) › ", true)
        end

        puts @pastel.bright_black("\n[project: #{@context.project_name}]\n")

        create_base_project
        add_front_end
        add_database
        add_test_files

        puts "\ninstall dependences:\n\n"
        puts "$ cd #{@context.project_name} && bundle"
        if @context.database?
          puts "\nput your dev database credentials in app/config/config.rb and migrate:\n\n"
          puts "$ rake db:migrate"
        end
        puts "\nrun and watch the project in dev mode:\n\n"
        puts "$ rake dev:watch"
        if @context.fullstack?
          puts "\ncompile and watch assets:\n\n"
          puts "$ rake assets:watch"
        end
        puts "\nrun 'rake' inside #{@context.project_name} to see all available tasks\n\n"
      rescue TTY::Reader::InputInterrupt
        puts "\n\nGoodbye"
      end

      private

      def fullstack_id = Roda::Project::FULLSTACK
      def mysql_id = Roda::Project::MYSQL
      def sqlite_id = Roda::Project::SQLITE
      def postgresql_id = Roda::Project::POSTGRESQL
      def api_id = Roda::Project::API

      def create_base_project
        puts "* creating base project"
        TTY::File.copy_directory(
          File.expand_path("../templates/base/scaffold", __dir__),
          "#{@dir}#{@context.project_name}",
          context: @context
        )
      end

      def add_front_end
        if @context.fullstack?
          puts "* adding front-end"
          tty_cp_r("front-end", "app/assets")
          tty_cp("front-end", "esbuild.js")
          tty_cp("front-end", "package.json")
          cp_r("front-end", "app/views")
        end
      end

      def add_database
        if @context.database?
          puts "* adding database"
          tty_cp_r("database", "db")
          tty_cp("database", "app/config/providers/db/conn.rb")
          add_rodauth
        end
      end

      def add_rodauth
        if @context.rodauth?
          puts "* adding rodauth"
          tty_cp_r("rodauth", "app/models")
          tty_cp("rodauth", "db/migrations/001_add_rodauth.rb")
          if @context.fullstack?
            cp("rodauth", "app/views/create-account.erb")
          end
        end
      end

      def add_test_files
        puts "* adding test files"
        tty_cp_r("tests/rspec", "spec")
      end
    end
  end
end
