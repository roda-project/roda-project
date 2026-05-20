# frozen_string_literal: true

require_relative "../../../lib/roda/project"
require_relative "../../../lib/roda/project/cli"

RSpec.describe Roda::Project::CLI do
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

  BASE_FILES_WITH_LOGIC =
    [
      "Gemfile",
      "boot.rb",
      "Rakefile",
      "app/app.rb",
      "app/routes/foo.rb",
      "app/config/config.rb",
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

  FRONT_FILES =
    [
      "app/views/foo/bar.erb",
      "app/views/foo/html.rb",
      "app/views/html.rb",
      "app/views/layout.erb",
      "esbuild.js",
      "package.json"
    ]

  context "when creating a fullstack project with database (SQLite) and Rodauth >" do
    let(:app_name) { "fullstack_sqlite_rodauth_project" }
    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, "1", true, "1", true
      )

      cli = described_class.new(dir:)
      cli.call
    end

    BASE_FILES_WITH_LOGIC.each do |path|
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

  context "when creating an API project without a database >" do
    let(:app_name) { "api_no_database_project" }
    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, "2", false
      )

      cli = described_class.new(dir:)
      cli.call
    end

    BASE_FILES_WITH_LOGIC.each do |path|
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
        app_name, "2", true, "2", true
      )

      cli = described_class.new(dir:)
      cli.call
    end

    BASE_FILES_WITH_LOGIC.each do |path|
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
        app_name, "1", true, "2", false
      )

      cli = described_class.new(dir:)
      cli.call
    end

    BASE_FILES_WITH_LOGIC.each do |path|
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
end
