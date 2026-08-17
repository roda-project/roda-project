# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/service"
require "tmpdir"
require "fileutils"

RSpec.describe Roda::Project::Bin::Generators::Service do
  let(:args) { ["class", "my_service"] }
  let(:generator) { described_class.new(args: args) }

  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  describe "#call" do
    context "when service_type is missing or invalid" do
      let(:args) { ["invalid_type", "my_service"] }

      it "prints usage and exits with status 1" do
        expect { generator.call }.to output(/Usage: bin\/roda g service <module\|class> <name>/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when service_name is missing" do
      let(:args) { ["class"] }

      it "prints usage and exits with status 1" do
        expect { generator.call }.to output(/Usage: bin\/roda g service <module\|class> <name>/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when service_name contains spaces" do
      let(:args) { ["class", "my service"] }

      it "prints usage and exits with status 1" do
        expect { generator.call }.to output(/Usage: bin\/roda g service <module\|class> <name>/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when service_name starts with a number" do
      let(:args) { ["class", "1service"] }

      it "prints usage and exits with status 1" do
        expect { generator.call }.to output(/Usage: bin\/roda g service <module\|class> <name>/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when service type is class and simple name" do
      let(:args) { ["class", "one_two_tree"] }

      it "generates class converted to camel case in app/services and spec scaffold" do
        expect { generator.call }.to output(
          include("app/services/one_two_tree.rb")
            .and(include("spec/app/services/one_two_tree_spec.rb"))
        ).to_stdout

        expect(File.exist?("app/services/one_two_tree.rb")).to be true
        expect(File.read("app/services/one_two_tree.rb")).to eq("class OneTwoTree\nend\n")

        expect(File.exist?("spec/app/services/one_two_tree_spec.rb")).to be true
        expect(File.read("spec/app/services/one_two_tree_spec.rb")).to eq(
          "require_relative \"../../spec_helper\"\n\ndescribe OneTwoTree do\nend\n"
        )
      end
    end

    context "when service type is module and simple name" do
      let(:args) { ["module", "my_service"] }

      it "generates module in app/services and spec scaffold" do
        expect { generator.call }.to output(
          include("app/services/my_service.rb")
            .and(include("spec/app/services/my_service_spec.rb"))
        ).to_stdout

        expect(File.exist?("app/services/my_service.rb")).to be true
        expect(File.read("app/services/my_service.rb")).to eq("module MyService\nend\n")

        expect(File.exist?("spec/app/services/my_service_spec.rb")).to be true
        expect(File.read("spec/app/services/my_service_spec.rb")).to eq(
          "require_relative \"../../spec_helper\"\n\ndescribe MyService do\nend\n"
        )
      end
    end

    context "when service name has nested paths (my/service/one)" do
      let(:args) { ["class", "my/service/one"] }

      it "generates nested modules and leaf class" do
        expect { generator.call }.to output(
          include("app/services/my/service/one.rb")
            .and(include("spec/app/services/my/service/one_spec.rb"))
        ).to_stdout

        expect(File.exist?("app/services/my/service/one.rb")).to be true
        expected_code = <<~RUBY
          module My
            module Service
              class One
              end
            end
          end
        RUBY
        expect(File.read("app/services/my/service/one.rb")).to eq(expected_code)

        expect(File.exist?("spec/app/services/my/service/one_spec.rb")).to be true
        expected_spec_code = <<~RUBY
          require_relative "../../../../spec_helper"

          describe My::Service::One do
          end
        RUBY
        expect(File.read("spec/app/services/my/service/one_spec.rb")).to eq(expected_spec_code)
      end
    end
  end
end
