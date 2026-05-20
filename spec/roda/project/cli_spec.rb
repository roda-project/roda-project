# frozen_string_literal: true

require "pastel"
require "tty-reader"
require "tty-file"
require "fileutils"

RSpec.describe Roda::Project::CLI do
  let(:context) { instance_double(Roda::Project::Context) }
  let(:pastel) { double(Pastel) } # Changed to double
  let(:reader) { instance_double(TTY::Reader) }

  # Mock constants
  before do
    stub_const("Roda::Project::VERSION", "0.1.0")
    stub_const("Roda::Project::FULLSTACK", 2) # Changed to integer
    stub_const("Roda::Project::API", 1)       # Changed to integer
    stub_const("Roda::Project::MYSQL", 3)     # Changed to integer
    stub_const("Roda::Project::POSTGRESQL", 2) # Changed to integer
    stub_const("Roda::Project::SQLITE", 1)    # Changed to integer

    # Stub TTY::Reader and Pastel interactions
    allow(TTY::Reader).to receive(:new).and_return(reader)
    # allow(reader).to receive(:read_line) # This will be handled by specific contexts
    allow(pastel).to receive(:bright_black) { |arg| arg }
    allow($stdout).to receive(:puts) # Suppress puts output during tests
  end

  subject(:cli) { described_class.new(context: context, pastel: pastel) }

  # Helper to set up common stubs for context methods
  def stub_context_methods(db_enabled: false, fs_enabled: false, rodauth_enabled: false)
    allow(context).to receive(:project_name=)
    allow(context).to receive(:base=)
    allow(context).to receive(:database=)
    allow(context).to receive(:database_type=)
    allow(context).to receive(:rodauth=)
    allow(context).to receive(:database?).and_return(db_enabled)
    allow(context).to receive(:fullstack?).and_return(fs_enabled)
    allow(context).to receive(:rodauth?).and_return(rodauth_enabled)
    allow(context).to receive(:project_name).and_return("test_app") # Default project name for private methods
  end

  describe "#initialize" do
    before do
      stub_context_methods # Default to all false for initial setup
    end

    it "initializes Pastel and prints version" do
      # Ensure read_line is stubbed for the version print to avoid NoMethodError
      allow(reader).to receive(:read_line).with("Project name › ").and_return("my_app") # Corrected
      allow(reader).to receive(:read_line).with("(1) Fullstack (2) API › ").and_return("1") # Corrected
      allow(reader).to receive(:read_line).with("Database? (Y/n) › ").and_return("n") # No database for this test
      expect(pastel).to receive(:bright_black).with("[roda-project v0.1.0]\n")
      expect($stdout).to receive(:puts).with("[roda-project v0.1.0]\n").at_least(:once)
      cli
    end

    context "when user provides inputs for a fullstack app with database and rodauth" do
      before do
        # Stub read_line calls in sequence
        allow(reader).to receive(:read_line).with("Project name › ").and_return("my_app") # Corrected
        allow(reader).to receive(:read_line).with("(1) Fullstack (2) API › ").and_return("2") # Fullstack (integer 2) # Corrected
        allow(reader).to receive(:read_line).with("Database? (Y/n) › ").and_return("Y") # Database # Corrected
        allow(reader).to receive(:read_line).with("(1) SQlite (2) PostgreSQL (3) MySQL › ").and_return("1") # SQLite (integer 1) # Corrected
        allow(reader).to receive(:read_line).with("Rodauth? (authentication) (Y/n) › ").and_return("Y") # Rodauth # Corrected

        # Stub context methods that are called during initialization
        stub_context_methods(db_enabled: true, fs_enabled: true, rodauth_enabled: true)
      end

      it "sets context attributes based on user input" do
        expect(context).to receive(:project_name=).with("my_app")
        expect(context).to receive(:base=).with(Roda::Project::FULLSTACK) # Expect integer
        expect(context).to receive(:database=).with(true)
        expect(context).to receive(:database_type=).with(Roda::Project::SQLITE) # Expect integer
        expect(context).to receive(:rodauth=).with(true)
        cli
      end
    end

    context "when user interrupts input" do
      before do
        allow(reader).to receive(:read_line).and_raise(TTY::Reader::InputInterrupt)
        stub_context_methods # Ensure context methods are stubbed even if init fails early
      end

      it "prints goodbye message" do
        expect($stdout).to receive(:puts).with("\n\nGoodbye")
        cli
      end
    end
  end

  describe "#call" do
    before do
      # Stub initialize's read_line calls to avoid interactive input during #call tests
      # These values will be used by the CLI#initialize when the subject(:cli) is created
      allow(reader).to receive(:read_line).with("Project name › ").and_return("test_app") # Corrected
      allow(reader).to receive(:read_line).with("(1) Fullstack (2) API › ").and_return("2") # Fullstack # Corrected
      allow(reader).to receive(:read_line).with("Database? (Y/n) › ").and_return("Y") # Database # Corrected
      allow(reader).to receive(:read_line).with("(1) SQlite (2) PostgreSQL (3) MySQL › ").and_return("1") # SQLite # Corrected
      allow(reader).to receive(:read_line).with("Rodauth? (authentication) (Y/n) › ").and_return("Y") # Rodauth # Corrected

      stub_context_methods(db_enabled: true, fs_enabled: true, rodauth_enabled: true)

      # Stub internal methods called by #call
      allow(cli).to receive(:create_base_project)
      allow(cli).to receive(:add_front_end)
      allow(cli).to receive(:add_database)
    end

    it "prints project name" do
      expect(pastel).to receive(:bright_black).with("\n[project: test_app]\n")
      expect($stdout).to receive(:puts).with("\n[project: test_app]\n").at_least(:once)
      cli.call
    end

    it "calls project creation methods" do
      expect(cli).to receive(:create_base_project)
      expect(cli).to receive(:add_front_end)
      expect(cli).to receive(:add_database)
      cli.call
    end

    it "prints final instructions" do
      expect($stdout).to receive(:puts).with("\nrun rake to see all available tasks\n\n")
      cli.call
    end
  end

  describe "private methods" do
    let(:project_root) { File.expand_path("../../../../", __dir__) }
    let(:template_base_path) { File.join(project_root, "lib", "roda", "templates") }
    let(:project_name) { "test_app" } # Changed to test_app

    before do
      # Stub initialize's read_line calls
      allow(reader).to receive(:read_line).with("Project name › ").and_return("my_app") # Corrected
      allow(reader).to receive(:read_line).with("(1) Fullstack (2) API › ").and_return("2") # Corrected
      allow(reader).to receive(:read_line).with("Database? (Y/n) › ").and_return("Y") # Corrected
      allow(reader).to receive(:read_line).with("(1) SQlite (2) PostgreSQL (3) MySQL › ").and_return("1") # Corrected
      allow(reader).to receive(:read_line).with("Rodauth? (authentication) (Y/n) › ").and_return("Y") # Corrected

      stub_context_methods(db_enabled: true, fs_enabled: true, rodauth_enabled: true)

      # Stub TTY::File and FileUtils methods
      allow(TTY::File).to receive(:copy_directory)
      allow(TTY::File).to receive(:copy_file)
      allow(FileUtils).to receive(:cp_r)
      allow(File).to receive(:write)
      allow(File).to receive(:read).and_return("file content") # For cp method
    end

    describe "#create_base_project" do
      it "copies the base scaffold" do
        expect($stdout).to receive(:puts).with("* creating base project")
        expected_source_path_literal = "/home/henrique/projects/roda-project/lib/roda/templates/base/scaffold"
        expect(TTY::File).to receive(:copy_directory).with(
          expected_source_path_literal,
          project_name, # Now "test_app"
          context: context
        )
        cli.__send__(:create_base_project)
      end
    end

    describe "#add_front_end" do
      context "when fullstack?" do
        before { allow(context).to receive(:fullstack?).and_return(true) }

        it "copies front-end assets and files" do
          expect($stdout).to receive(:puts).with("* adding front-end")
          expect(cli).to receive(:tty_cp_r).with("front-end", "app/assets")
          expect(cli).to receive(:tty_cp).with("front-end", "esbuild.js")
          expect(cli).to receive(:tty_cp).with("front-end", "package.json")
          expect(cli).to receive(:cp_r).with("front-end", "app/views")
          cli.__send__(:add_front_end)
        end
      end

      context "when not fullstack?" do
        before { allow(context).to receive(:fullstack?).and_return(false) }

        it "does not copy front-end assets and files" do
          expect($stdout).not_to receive(:puts).with("* adding front-end")
          expect(cli).not_to receive(:tty_cp_r)
          expect(cli).not_to receive(:tty_cp)
          expect(cli).not_to receive(:cp_r)
          cli.__send__(:add_front_end)
        end
      end
    end

    describe "#add_database" do
      context "when database?" do
        before do
          allow(context).to receive(:database?).and_return(true)
          allow(cli).to receive(:add_rodauth) # Stub add_rodauth to test add_database in isolation
        end

        it "copies database files and calls add_rodauth" do
          expect($stdout).to receive(:puts).with("* adding database")
          expect(cli).to receive(:tty_cp_r).with("database", "db")
          expect(cli).to receive(:tty_cp).with("database", "app/config/providers/db/conn.rb")
          expect(cli).to receive(:add_rodauth)
          cli.__send__(:add_database)
        end
      end

      context "when not database?" do
        before { allow(context).to receive(:database?).and_return(false) }

        it "does not copy database files and does not call add_rodauth" do
          expect($stdout).not_to receive(:puts).with("* adding database")
          expect(cli).not_to receive(:tty_cp_r)
          expect(cli).not_to receive(:tty_cp)
          expect(cli).not_to receive(:add_rodauth)
          cli.__send__(:add_database)
        end
      end
    end

    describe "#add_rodauth" do
      context "when rodauth?" do
        before { allow(context).to receive(:rodauth?).and_return(true) }

        it "copies rodauth files" do
          expect($stdout).to receive(:puts).with("* adding rodauth")
          expect(cli).to receive(:tty_cp_r).with("rodauth", "app/models")
          expect(cli).to receive(:tty_cp).with("rodauth", "db/migrations/001_add_rodauth.rb")
          cli.__send__(:add_rodauth)
        end

        context "and fullstack?" do
          before { allow(context).to receive(:fullstack?).and_return(true) }

          it "copies create-account.erb" do
            expect(cli).to receive(:cp).with("rodauth", "app/views/create-account.erb")
            cli.__send__(:add_rodauth)
          end
        end

        context "and not fullstack?" do
          before { allow(context).to receive(:fullstack?).and_return(false) }

          it "does not copy create-account.erb" do
            expect(cli).not_to receive(:cp).with("rodauth", "app/views/create-account.erb")
            cli.__send__(:add_rodauth)
          end
        end
      end

      context "when not rodauth?" do
        before do
          allow(context).to receive(:rodauth?).and_return(false)
          # Stub add_database to prevent it from calling add_rodauth
          allow(cli).to receive(:add_database) do
            # Simulate add_database logic without calling add_rodauth
            if context.database?
              expect($stdout).to receive(:puts).with("* adding database")
              expect(cli).to receive(:tty_cp_r).with("database", "db")
              expect(cli).to receive(:tty_cp).with("database", "app/config/providers/db/conn.rb")
            end
          end
        end

        it "does not copy rodauth files" do
          expect($stdout).not_to receive(:puts).with("* adding rodauth")
          expect(cli).not_to receive(:tty_cp_r)
          expect(cli).not_to receive(:tty_cp)
          expect(cli).not_to receive(:cp).with("rodauth", "app/views/create-account.erb")
          cli.__send__(:add_rodauth)
        end
      end
    end
  end
end