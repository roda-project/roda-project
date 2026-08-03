# frozen_string_literal: true

module Roda
  module Project
    class CLI < Generator
      include Helpers::InteractiveInput

      def call
        puts pastel.bright_black("[roda-project v#{Roda::Project::VERSION}]\n")
        puts pastel.italic("#{Roda::Project.messages.sample.first}\n")

        get_user_context

        puts pastel.bright_black("\n[project: #{@context.project_name}]\n")

        create_base_project
        add_front_end
        add_database
        add_test_files

        puts "\ninstall dependences:\n\n"
        puts "$ cd #{@context.project_name} && bundle"
        if @context.database?
          unless @context.sqlite?
            puts "\n* create your database\n"
            puts "\n* put your dev database credentials in app/config/config.rb\n"
          end
          puts "\nmigrate the database (use RACK_ENV to migrate 'test' or 'production' environments):\n\n"
          puts "$ bin/roda db migrate"
        end
        puts "\nrun and watch the project in dev mode:\n"
        puts "\n$ bin/roda dev"
        if @context.fullstack?
          puts "\ncompile and watch assets:\n"
          puts "\n$ bin/roda assets:dev"
        end
        puts "\nrun 'bin/roda' inside #{@context.project_name} to see all available tasks\n\n"
      rescue TTY::Reader::InputInterrupt
        puts "\n\nGoodbye"
      end

      private

      def get_user_context
        retry_on_error { @context.project_name = read_line("Project name › ", "project") }
        retry_on_error { @context.base = read_line("(#{fullstack_id}) Fullstack (#{api_id}) API (#{minimal_id}) Minimal › ", fullstack_id).to_i }
        retry_on_error { @context.tests = read_line("(#{rspec_id}) RSpec (#{minitest_id}) Minitest › ", rspec_id).to_i }

        unless @context.minimal?
          retry_on_error { @context.database = read_line("Database? (Y/n) › ", true) }

          if @context.database?
            retry_on_error {
              @context.database_type = read_line(
                "(#{sqlite_id}) SQlite (#{postgresql_id}) PostgreSQL (#{mysql_id}) MySQL › ",
                sqlite_id
              ).to_i
            }

            retry_on_error { @context.rodauth = read_line("Rodauth? (authentication) (Y/n) › ", true) }
          end
        end
      end

      def create_base_project
        puts "* creating base project"
        if @context.minimal?
          TTY::File.copy_directory(
            File.expand_path("templates/base/minimal", __dir__),
            "#{@dir}#{@context.project_name}",
            context: @context
          )

          return
        end

        TTY::File.copy_directory(
          File.expand_path("templates/base/scaffold", __dir__),
          "#{@dir}#{@context.project_name}",
          context: @context
        )

        TTY::File.copy_file(
          File.expand_path("templates/base/app/app.rb.erb", __dir__),
          "#{@dir}#{@context.project_name}/app/#{@context.project_name}.rb",
          context: @context
        )

        TTY::File.chmod("#{@dir}#{@context.project_name}/bin/roda", "+x")
      end

      def add_front_end
        if @context.fullstack?
          puts "* adding front-end"
          erb_cp_dir("front-end", "app/assets")
          erb_cp_file("front-end", "esbuild.js")
          erb_cp_file("front-end", "package.json")
          cp_dir("front-end", "app/views")
          cp_dir("front-end", "app/views")
          cp_dir("front-end", "public/assets")
          cp_dir("front-end", "public/images")
        end
      end

      def add_database
        if @context.database?
          puts "* adding database"
          erb_cp_dir("database", "db")
          erb_cp_file("database", "app/config/providers/db/conn.rb")
          add_rodauth
        end
      end

      def add_rodauth
        if @context.rodauth?
          puts "* adding rodauth"
          erb_cp_dir("rodauth", "app/models")
          erb_cp_file("rodauth", "db/migrations/001_add_rodauth.rb")
          if @context.fullstack?
            cp_file("rodauth", "app/views/create-account.erb")
          end
        end
      end

      def add_test_files
        puts "* adding test files"
        minimal_dir = @context.minimal? ? "minimal/" : ""

        if @context.rspec?
          erb_cp_dir("tests/#{minimal_dir}rspec", "spec")
        else
          erb_cp_dir("tests/#{minimal_dir}minitest", "spec")
        end
      end
    end
  end
end
