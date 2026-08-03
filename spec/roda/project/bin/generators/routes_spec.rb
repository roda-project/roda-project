# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/routes"
require "tmpdir"
require "fileutils"

RSpec.describe Roda::Project::Bin::Generators::Routes do
  let(:context) { double("MainContext", const_project_name: "TestProject") }
  let(:args) { ["users", "index", "create:post"] }
  let(:options) { { views: false } }
  let(:generator) do
    described_class.new(context: context, args: args, options: options)
  end

  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  describe "#call" do
    context "when branch_name is missing" do
      let(:args) { [] }

      it "prints usage and exits with status 1" do
        expect { generator.call }.to output(/Usage: bin\/roda g routes/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when routes_list is missing" do
      let(:args) { ["users"] }

      it "prints usage and exits with status 1" do
        expect { generator.call }.to output(/Usage: bin\/roda g routes/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when arguments are valid" do
      before do
        allow($stdout).to receive(:puts)
      end

      it "generates the routes file correctly" do
        generator.call

        routes_file = "app/routes/users.rb"
        expect(File.exist?(routes_file)).to be true

        content = File.read(routes_file)
        expect(content).to include("class TestProject")
        expect(content).to include("hash_branch \"users\" do |r|")
        expect(content).to include("r.get \"index\" do")
        expect(content).to include("r.post \"create\" do")
        expect(content).not_to include("view('index')")
      end

      it "generates the tests file correctly" do
        generator.call

        test_file = "spec/app/routes/users_spec.rb"
        expect(File.exist?(test_file)).to be true

        content = File.read(test_file)
        expect(content).to include("require_relative \"../../spec_helper\"")
        expect(content).to include("describe \"Routes for users\" do")
        expect(content).to include("it \"responds to GET /users/index\" do")
        expect(content).to include("get \"/users/index\"")
        expect(content).to include("it \"responds to POST /users/create\" do")
        expect(content).to include("post \"/users/create\"")
      end

      context "with nested branch_name" do
        let(:args) { ["admin/users", "list:get"] }

        it "creates nested directories and correct spec helper path" do
          generator.call

          expect(File.exist?("app/routes/admin/users.rb")).to be true
          expect(File.exist?("spec/app/routes/admin/users_spec.rb")).to be true

          content = File.read("spec/app/routes/admin/users_spec.rb")
          expect(content).to include("require_relative \"../../../spec_helper\"")
        end
      end

      context "when views option is true" do
        let(:options) { { views: true } }

        context "and app/views directory exists" do
          before do
            FileUtils.mkdir_p("app/views")
          end

          it "adds view to get routes and creates view files" do
            generator.call

            # Routes file
            routes_content = File.read("app/routes/users.rb")
            expect(routes_content).to include("view('index')")
            # post route shouldn't have view
            expect(routes_content).not_to include("view('create')")

            # Views files
            expect(File.exist?("app/views/users/index.erb")).to be true
            expect(File.exist?("app/views/users/create.erb")).to be false
          end
        end

        context "and app/views directory does not exist" do
          it "does not add views or create view files" do
            generator.call

            expect(File.directory?("app/views/users")).to be false
            routes_content = File.read("app/routes/users.rb")
            expect(routes_content).not_to include("view('index')")
          end
        end
      end
    end
  end
end
