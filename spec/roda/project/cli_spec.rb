# frozen_string_literal: true

require_relative "../../../lib/roda/project"
require_relative "../../../lib/roda/project/cli"

RSpec.describe Roda::Project::CLI do
  after { FileUtils.rm_rf(tmp_path) }
  let(:tmp_path) { File.expand_path("../../tmp", __dir__) }
  let(:dir) { 'spec/tmp/' }

  before { allow($stdout).to receive(:write) }

  def file(name)
    File.read("#{tmp_path}/#{app_name}/#{name}")
  end

  def snap(name)
    "#{app_name}/#{name}"
  end

  context "when creating a fullstack project with database (SQLite) and Rodauth" do
    let(:app_name) { 'fullstack_sqlite_rodauth_project' }
    before do
      allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        app_name, "1", "y", "1", "y"
      )

      cli = described_class.new(dir:)
      cli.call
    end

    [
      "Gemfile",
      "boot.rb",
      "Rakefile",
      "app/app.rb",
      "app/routes/foo.rb",
      "app/config/config.rb",
    ].each do |path|
      it "generates the correct project structure and files (#{path})" do
        expect(file(path)).to match_snapshot(snap(path))
      end
    end
  end

  #context "when creating an API project without a database" do
    #let(:app_name) { 'api_no_database_project' }

    #it "generates the correct project structure and files" do
      #allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        #"my_api_app",
        #"2",
        #"n"
      #)

      #cli = described_class.new(dir:)
      #cli.call

      #expect(Pathname.new("my_api_app")).to match_snapshot("api_no_database_project")
    #end
  #end

  #context "when creating a fullstack project with database (PostgreSQL) but no Rodauth" do
    #let(:app_name) { "fullstack_pg_no_rodauth_project" }

    #it "generates the correct project structure and files" do
      #allow_any_instance_of(Roda::Project::CLI).to receive(:read_line).and_return(
        #"my_fullstack_pg_app",
        #"1",
        #"y",
        #"2",
        #"n"
      #)

      #cli = described_class.new(dir:)
      #cli.call

      #expect(Pathname.new("my_fullstack_pg_app")).to match_snapshot("fullstack_pg_no_rodauth_project")
    #end
  #end
end
