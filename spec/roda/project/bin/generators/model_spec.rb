# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/model"
require "tmpdir"
require "fileutils"

RSpec.describe Roda::Project::Bin::Generators::Model do
  let(:args) { ["User", "name:string", "email:string"] }
  let(:generator) { described_class.new(args: args) }

  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  describe "#call" do
    context "when model_name is missing" do
      let(:args) { [] }

      it "prints usage and exits with status 1" do
        allow(generator).to receive(:model_name).and_return(nil)
        expect { generator.call }.to output(/Usage: bin\/roda g model name field1 field2/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when field_args is empty" do
      let(:args) { ["User"] }

      it "prints usage and exits with status 1" do
        expect { generator.call }.to output(/Usage: bin\/roda g model name field1 field2/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when model_name contains '/'" do
      let(:args) { ["admin/user", "name:string"] }

      it "prints warning about nested models not supported and exits with status 1" do
        expect { generator.call }.to output(/'\/' nested models not supported/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when valid arguments are provided" do
      let(:migration_instance) { instance_double(Roda::Project::Bin::Generators::Migration) }

      before do
        allow(Roda::Project::Bin::Generators::Migration).to receive(:new).and_return(migration_instance)
        allow(migration_instance).to receive(:call)
      end

      it "creates model file and test file, and calls Migration generator" do
        expect { generator.call }.to output(
          include("* created model file: app/models/user.rb")
            .and(include("* created model spec file: spec/app/models/user_spec.rb"))
        ).to_stdout

        expect(File.exist?("app/models/user.rb")).to be true
        expect(File.read("app/models/user.rb")).to eq("class User\nend\n")

        expect(File.exist?("spec/app/models/user_spec.rb")).to be true
        expect(File.read("spec/app/models/user_spec.rb")).to eq("require_relative \"../../spec_helper\"\n\ndescribe User do\nend\n")

        expect(Roda::Project::Bin::Generators::Migration).to have_received(:new).with(
          args: ["CreateUsers", "name:string", "email:string"]
        )
        expect(migration_instance).to have_received(:call)
      end
    end
  end

  describe "#model_name" do
    context "when input is snake_case" do
      let(:args) { ["user_profile"] }

      it "camelizes the model name" do
        expect(generator.model_name).to eq("UserProfile")
      end
    end
  end

  describe "#migration_name" do
    let(:args) { ["product_category"] }

    it "builds migration name with 'Create' prefix and pluralized model name" do
      expect(generator.migration_name).to eq("CreateProductCategories")
    end
  end

  describe "#field_args" do
    context "when multiple fields are supplied" do
      let(:args) { ["User", "name:string", "age:integer"] }

      it "returns array of field arguments" do
        expect(generator.field_args).to eq(["name:string", "age:integer"])
      end
    end

    context "when no fields are supplied" do
      let(:args) { ["User"] }

      it "returns an empty array" do
        expect(generator.field_args).to eq([])
      end
    end
  end
end
