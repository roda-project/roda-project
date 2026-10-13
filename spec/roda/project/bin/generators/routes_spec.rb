# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/routes"
require "tmpdir"
require "fileutils"

RSpec.describe Roda::Project::Bin::Generators::Routes do
  let(:context) { double("MainContext", const_project_name: "TestProject") }
  let(:args) { ["users", "get:index", "post:create"] }
  let(:options) { {views: false} }
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

      context "when route name is empty (root route)" do
        let(:args) { ["users", "get", "post"] }

        it "generates the root routes in the route file without a string name" do
          generator.call

          routes_content = File.read("app/routes/users.rb")
          expect(routes_content).to include("r.get do\n    end")
          expect(routes_content).to include("r.post do\n    end")
        end

        it "generates the corresponding root route tests" do
          generator.call

          test_content = File.read("spec/app/routes/users_spec.rb")

          # Notice: Asserts the exact string rendered by the generator (including the missing closing quotes)
          expect(test_content).to include("it \"responds to GET /users\" do")
          expect(test_content).to include("get \"/users\"\n")
          expect(test_content).to include("it \"responds to POST /users\" do")
          expect(test_content).to include("post \"/users\"\n")
        end

        context "when views option is true" do
          let(:options) { {views: true} }

          before do
            FileUtils.mkdir_p("app/views")
          end

          it "defaults view name to 'index'" do
            generator.call

            routes_content = File.read("app/routes/users.rb")
            expect(routes_content).to include("r.get do\n      view('index')\n    end")
            expect(File.exist?("app/views/users/index.erb")).to be true
          end
        end
      end

      context "with nested branch_name" do
        context "with single sublevel (e.g. a/b)" do
          let(:args) { ["admin/users", "get:list"] }

          it "creates nested directories, correct hash_branch format" do
            generator.call

            expect(File.exist?("app/routes/admin/users.rb")).to be true
            expect(File.exist?("spec/app/routes/admin/users_spec.rb")).to be true
            expect(File.exist?("app/routes/admin.rb")).to be true

            admin_content = File.read("app/routes/admin.rb")
            expect(admin_content).to include("class TestProject")
            expect(admin_content).to include('hash_branch "admin" do |r|')
            expect(admin_content).to include("r.hash_branches(:admin)")

            routes_content = File.read("app/routes/admin/users.rb")
            expect(routes_content).to include("hash_branch :admin, \"users\" do |r|")

            content = File.read("spec/app/routes/admin/users_spec.rb")
            expect(content).to include("require_relative \"../../../spec_helper\"")
          end
        end

        context "with multiple sublevels (e.g. a/b/c)" do
          let(:args) { ["a/b/c", "get:show"] }

          it "creates correct hash_branch format for deep nesting" do
            generator.call

            expect(File.exist?("app/routes/a/b/c.rb")).to be true
            expect(File.exist?("app/routes/a.rb")).to be true
            expect(File.exist?("app/routes/a/b.rb")).to be true

            a_content = File.read("app/routes/a.rb")
            expect(a_content).to include('hash_branch "a" do |r|')
            expect(a_content).to include("r.hash_branches(:a)")

            ab_content = File.read("app/routes/a/b.rb")
            expect(ab_content).to include('hash_branch :a, "b" do |r|')
            expect(ab_content).to include('r.hash_branches(:"a/b")')

            routes_content = File.read("app/routes/a/b/c.rb")
            expect(routes_content).to include("hash_branch :\"a/b\", \"c\" do |r|")
          end
        end

        context "with four sublevels (e.g. a/b/c/d)" do
          let(:args) { ["a/b/c/d", "get:show"] }

          it "creates correct hash_branch format for four sublevels" do
            generator.call

            expect(File.exist?("app/routes/a/b/c/d.rb")).to be true
            expect(File.exist?("app/routes/a.rb")).to be true
            expect(File.exist?("app/routes/a/b.rb")).to be true
            expect(File.exist?("app/routes/a/b/c.rb")).to be true

            abc_content = File.read("app/routes/a/b/c.rb")
            expect(abc_content).to include('hash_branch :"a/b", "c" do |r|')
            expect(abc_content).to include('r.hash_branches(:"a/b/c")')

            routes_content = File.read("app/routes/a/b/c/d.rb")
            expect(routes_content).to include("hash_branch :\"a/b/c\", \"d\" do |r|")
          end
        end

        context "when an intermediate branch file already exists" do
          let(:args) { ["admin/users", "get:list"] }

          before do
            FileUtils.mkdir_p("app/routes/admin")
          end

          it "does not overwrite it and prints no warning when the hash_branches line is present" do
            original = "class TestProject\n  hash_branch \"admin\" do |r|\n    r.hash_branches(:admin)\n  end\nend\n"
            File.write("app/routes/admin.rb", original)

            expect { generator.call }.not_to output(/warning/).to_stdout
            expect(File.read("app/routes/admin.rb")).to eq(original)
          end

          it "notifies the user when the hash_branches line is missing, without modifying the file" do
            original = "class TestProject\n  hash_branch \"admin\" do |r|\n  end\nend\n"
            File.write("app/routes/admin.rb", original)

            expect { generator.call }.to output(/app\/routes\/admin\.rb already exists.*r\.hash_branches\(:admin\)/m).to_stdout
            expect(File.read("app/routes/admin.rb")).to eq(original)
          end
        end
      end

      context "when views option is true" do
        let(:options) { {views: true} }

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
