# frozen_string_literal: true

require_relative "../../../lib/roda/project"
require_relative "../../../lib/roda/project/cli"
require "json"

# rubocop:disable Lint/ConstantDefinitionInBlock
RSpec.describe Roda::Project::CLI do
  include Roda::Project::Helpers::Ids

  after { FileUtils.rm_rf(tmp_path) }
  let(:tmp_path) { File.expand_path("../../tmp", __dir__) }
  let(:dir) { "spec/tmp/" }

  before { allow($stdout).to receive(:write) }

  def file_exist?(name)
    ::File.exist?("#{tmp_path}/#{app_name}/#{name}")
  end

  def file(name)
    File.read("#{tmp_path}/#{app_name}/#{name}")
  end

  def snap(name)
    "#{app_name}/#{name}"
  end

  BASE_MINIMAL_FILES_WITH_LOGIC =
    [
      "Gemfile",
      "bin/roda"
    ]

  BASE_SCAFFOLD_FILES_WITH_LOGIC =
    [
      "Gemfile",
      "boot.rb",
      "AGENTS.md",
      "bin/roda",
      "app/routes/foo.rb",
      "app/config/config.rb",
      "spec/app/app_spec.rb",
      "spec/app/routes/foo_spec.rb",
      "spec/app/app_spec.rb",
      "spec/spec_helper.rb"
    ]

  RODAUTH_FRONT_FILES =
    [
      "app/views/create-account.erb"
    ]

  DB_FILES =
    [
      "app/config/providers/db/conn.rb"
    ]

  RODAUTH_BACK_FILES =
    [
      "app/models/account.rb",
      "db/migrations/001_add_rodauth.rb"
    ]

  INERTIA_FILES =
    [
      "app/assets/js/inertia/views/Index.jsx",
      "app/assets/js/inertia/components/Layout.jsx",
      "babel.config.js",
      "jest.config.js",
      "jest.setup.js",
      "jest.inertia-mock.js"
    ]

  FRONT_FILES =
    [
      "app/views/foo/bar.erb",
      "app/views/layout.erb",
      "app/assets/js/app.js",
      "app/config/locales/en.yml",
      "app/config/locales/pt-br.yml",
      "app/config/locales/foo/en.yml",
      "app/config/locales/foo/pt-br.yml",
      "esbuild.js",
      "package.json"
    ]

  context "when creating a fullstack project with minitest, database (SQLite) and Rodauth >" do
    let(:app_name) { "fullstack_sqlite_rodauth_project" }
    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, fullstack_id, erb_id, minitest_id, true, sqlite_id, true
      )

      cli = described_class.new(dir:)
      cli.call
    end

    (BASE_SCAFFOLD_FILES_WITH_LOGIC + ["app/fullstack_sqlite_rodauth_project.rb"]).each do |path|
      it "generates the correct: #{path}" do
        expect(file(path)).to match_snapshot(snap(path))
      end
    end

    (FRONT_FILES + DB_FILES + RODAUTH_BACK_FILES + RODAUTH_FRONT_FILES)
      .each do |path|
      it "#{path} exist" do
        expect(file_exist?(path)).to(be_truthy)
      end
    end
  end

  context "when creating a fullstack project with RSpec, inertia.js, database (MySQL) and Rodauth >" do
    let(:app_name) { "fullstack_mysql_inertia_rspec_rodauth_project" }
    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, fullstack_id, inertia_id, rspec_id, true, mysql_id, true
      )

      cli = described_class.new(dir:)
      cli.call
    end

    (BASE_SCAFFOLD_FILES_WITH_LOGIC + ["app/fullstack_mysql_inertia_rspec_rodauth_project.rb"]).each do |path|
      it "generates the correct: #{path}" do
        expect(file(path)).to match_snapshot(snap(path))
      end
    end

    (FRONT_FILES + INERTIA_FILES + DB_FILES + RODAUTH_BACK_FILES + RODAUTH_FRONT_FILES)
      .each do |path|
        it "#{path} exist" do
          expect(file_exist?(path)).to(be_truthy)
        end
      end

    it "installs the @testing-library/dom peer dependency required by @testing-library/react" do
      dev_dependencies = JSON.parse(file("package.json"))["devDependencies"]

      expect(dev_dependencies["@testing-library/dom"]).to eq("^10.4.2")
    end

    it "maps @inertiajs/react to the jest mock so its ESM build is not loaded" do
      expect(file("jest.config.js")).to include("'^@inertiajs/react$': '<rootDir>/jest.inertia-mock.js'")
    end
  end

  context "when creating an API project without a database >" do
    let(:app_name) { "api_no_database_project" }
    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, "2", "1", false
      )

      cli = described_class.new(dir:)
      cli.call
    end

    (BASE_SCAFFOLD_FILES_WITH_LOGIC + ["app/api_no_database_project.rb"]).each do |path|
      it "generates the correct: #{path}" do
        expect(file(path)).to match_snapshot(snap(path))
      end
    end

    (FRONT_FILES + RODAUTH_BACK_FILES + RODAUTH_FRONT_FILES)
      .each do |path|
      it "#{path} dont exists" do
        expect(file_exist?(path)).to(be_falsey)
      end
    end
  end

  context "when creating a API project with database and Rodauth >" do
    let(:app_name) { "api_rodauth" }
    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, "2", "1", true, "2", true
      )

      cli = described_class.new(dir:)
      cli.call
    end

    (BASE_SCAFFOLD_FILES_WITH_LOGIC + ["app/api_rodauth.rb"]).each do |path|
      it "generates the correct: #{path}" do
        expect(file(path)).to match_snapshot(snap(path))
      end
    end

    (DB_FILES + RODAUTH_BACK_FILES)
      .each do |path|
        it "#{path} exist" do
          expect(file_exist?(path)).to(be_truthy)
        end
      end

    RODAUTH_FRONT_FILES
      .each do |path|
        it "#{path} dont exists" do
          expect(file_exist?(path)).to(be_falsey)
        end
      end
  end

  context "when creating a fullstack project with database (PostgreSQL) but no Rodauth >" do
    let(:app_name) { "fullstack_pg_no_rodauth_project" }
    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, "1", "1", "1", true, "2", false
      )

      cli = described_class.new(dir:)
      cli.call
    end

    (BASE_SCAFFOLD_FILES_WITH_LOGIC + ["app/fullstack_pg_no_rodauth_project.rb"]).each do |path|
      it "generates the correct: #{path}" do
        expect(file(path)).to match_snapshot(snap(path))
      end
    end

    (FRONT_FILES + DB_FILES)
      .each do |path|
      it "#{path} exist" do
        expect(file_exist?(path)).to(be_truthy)
      end
    end
  end

  context "when creating a minimal project with rspec >" do
    let(:app_name) { "minimal_rspec_project" }
    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, "3", "1"
      )

      cli = described_class.new(dir:)
      cli.call
    end

    BASE_MINIMAL_FILES_WITH_LOGIC.each do |path|
      it "generates the correct: #{path}" do
        expect(file(path)).to match_snapshot(snap(path))
      end
    end
  end

  context "when the project name is informed in CamelCase >" do
    let(:app_name) { "MyRodaApp" }
    let(:normalized_name) { "my_roda_app" }

    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, api_id, rspec_id, false
      )

      cli = described_class.new(dir:)
      cli.call
    end

    it "normalizes the folder, main app file and constant names" do
      expect(File.directory?("#{tmp_path}/#{normalized_name}")).to be(true)
      expect(File.exist?("#{tmp_path}/#{normalized_name}/app/#{normalized_name}.rb")).to be(true)
      expect(File.exist?("#{tmp_path}/#{app_name}")).to be(false)

      app_file = File.read("#{tmp_path}/#{normalized_name}/app/#{normalized_name}.rb")
      expect(app_file).to include("class MyRodaApp < Roda")
    end
  end

  context "when --jeremy option is passed" do
    let(:app_name) { "jeremy_project" }
    let(:jeremy_creator) { instance_double(Roda::Project::JeremyTemplateCreator) }

    before do
      stub_const("ARGV", ["--jeremy"])
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(app_name)
      allow(Roda::Project::JeremyTemplateCreator).to receive(:new).and_return(jeremy_creator)
      allow(jeremy_creator).to receive(:call)
    end

    it "invokes JeremyTemplateCreator and returns early without prompting further (lines 14 & 47)" do
      cli = described_class.new(dir: dir)

      expect(Roda::Project::JeremyTemplateCreator).to receive(:new).with(
        context: an_instance_of(Roda::Project::MainContext)
      ).and_return(jeremy_creator)
      expect(jeremy_creator).to receive(:call)

      cli.call

      expect(cli.send(:jeremy?)).to be(true)
    end
  end
end
# rubocop:enable Lint/ConstantDefinitionInBlock
