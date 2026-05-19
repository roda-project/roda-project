# frozen_string_literal: true

require "tty-file"
require 'fileutils'
require "tty-reader"
require "pastel"
require_relative "project/version"

module Roda
  module Project
    class Error < StandardError; end
    # Your code goes here...

    def self.call
      reader = TTY::Reader.new
      pastel = Pastel.new
      puts(pastel.bright_black("[roda-project v#{Roda::Project::VERSION}]\n"))

      project_name = reader.read_line("Project name › ").chomp
      project_name = (project_name == "")? "app" : project_name
      api = reader.read_line("(1) API (2) Fullstack › ").chomp
      database = reader.read_line("Database? (Y/n) › ").chomp
      if database != ""
      else
        database = reader.read_line("(1) SQlite (2) PostgreSQL (3) MySQL › ")
        auth = reader.read_line("Rodauth? (authentication) (Y/n) › ")
      end
      puts pastel.bright_black("\n[creating project: #{project_name}]\n")
      #TTY::File.copy_directory(
        #File.expand_path("../../../templates/dir", __dir__),
        #"dir"
      #)
      puts "* creating base project"
      TTY::File.copy_directory(
        File.expand_path("templates/base/fullstack", __dir__),
        "fullstack",
        context: {
          include_rodauth: true
        },
        verbose: false
      )

      puts "* including rodauth"
      FileUtils.cp_r(
        File.expand_path("templates/files/rodauth/app/models", __dir__),
        'fullstack/app/models'
      )
      FileUtils.cp(
        File.expand_path("templates/files/rodauth/db/migrations/001_add_rodauth.rb", __dir__),
        'fullstack/db/migrations/001_add_rodauth.rb'
      )

      puts "* including views"
      FileUtils.cp_r(
        File.expand_path("templates/files/views/app/views", __dir__),
        'fullstack/app/views'
      )

      puts "\nrun rake to see all available tasks\n\n"
    rescue TTY::Reader::InputInterrupt
      puts "\n\nGoodbye"
    end
  end
end
