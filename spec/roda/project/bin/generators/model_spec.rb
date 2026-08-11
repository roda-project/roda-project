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

    context "when valid arguments are provided (simple model)" do
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
        expect(File.read("spec/app/models/user_spec.rb")).to eq(
          "require_relative \"../../spec_helper\"\n\ndescribe User do\nend\n"
        )

        expect(Roda::Project::Bin::Generators::Migration).to have_received(:new).with(
          args: ["CreateUsers", "name:string", "email:string"]
        )
        expect(migration_instance).to have_received(:call)
      end
    end

    context "when model name has one namespace segment (admin/user)" do
      let(:args) { ["admin/user", "name:string"] }
      let(:migration_instance) { instance_double(Roda::Project::Bin::Generators::Migration) }

      before do
        allow(Roda::Project::Bin::Generators::Migration).to receive(:new).and_return(migration_instance)
        allow(migration_instance).to receive(:call)
      end

      it "creates nested model file with wrapped module" do
        expect { generator.call }.to output(
          include("* created model file: app/models/admin/user.rb")
            .and(include("* created model spec file: spec/app/models/admin/user_spec.rb"))
        ).to_stdout

        expect(File.exist?("app/models/admin/user.rb")).to be true

        model_content = File.read("app/models/admin/user.rb")
        expect(model_content).to include("module Admin")
        expect(model_content).to include("class User < Sequel::Model(:admin_users)")
        expect(model_content).to include("end")
      end

      it "creates nested spec file with correct require_relative depth" do
        generator.call

        expect(File.exist?("spec/app/models/admin/user_spec.rb")).to be true
        spec_content = File.read("spec/app/models/admin/user_spec.rb")
        # spec/ is 3 levels up from spec/app/models/
        expect(spec_content).to include("require_relative \"../../../spec_helper\"")
        expect(spec_content).to include("describe Admin::User do")
      end

      it "calls Migration with underscore-joined name" do
        generator.call

        expect(Roda::Project::Bin::Generators::Migration).to have_received(:new).with(
          args: ["CreateAdmin_Users", "name:string"]
        )
      end
    end

    context "when model name has two namespace segments (one/two/three)" do
      let(:args) { ["one/two/three", "title:string"] }
      let(:migration_instance) { instance_double(Roda::Project::Bin::Generators::Migration) }

      before do
        allow(Roda::Project::Bin::Generators::Migration).to receive(:new).and_return(migration_instance)
        allow(migration_instance).to receive(:call)
      end

      it "creates doubly-nested model file" do
        expect { generator.call }.to output(
          include("* created model file: app/models/one/two/three.rb")
        ).to_stdout

        expect(File.exist?("app/models/one/two/three.rb")).to be true

        model_content = File.read("app/models/one/two/three.rb")
        expect(model_content).to include("module One")
        expect(model_content).to include("module Two")
        expect(model_content).to include("class Three < Sequel::Model(:one_two_threes)")
      end

      it "creates doubly-nested spec file with correct require_relative" do
        generator.call

        expect(File.exist?("spec/app/models/one/two/three_spec.rb")).to be true
        spec_content = File.read("spec/app/models/one/two/three_spec.rb")
        # spec/ is 4 levels up from spec/app/models/one/two/
        expect(spec_content).to include("require_relative \"../../../../spec_helper\"")
        expect(spec_content).to include("describe One::Two::Three do")
      end

      it "calls Migration with CreateOne_Two_Threes" do
        generator.call

        expect(Roda::Project::Bin::Generators::Migration).to have_received(:new).with(
          args: ["CreateOne_Two_Threes", "title:string"]
        )
      end
    end

    context "when nested model name contains snake_case segments (admin/user_profile)" do
      let(:args) { ["admin/user_profile", "bio:text"] }
      let(:migration_instance) { instance_double(Roda::Project::Bin::Generators::Migration) }

      before do
        allow(Roda::Project::Bin::Generators::Migration).to receive(:new).and_return(migration_instance)
        allow(migration_instance).to receive(:call)
      end

      it "camelizes each segment correctly" do
        generator.call

        model_content = File.read("app/models/admin/user_profile.rb")
        expect(model_content).to include("module Admin")
        expect(model_content).to include("class UserProfile < Sequel::Model(:admin_user_profiles)")
      end

      it "builds migration name correctly" do
        generator.call

        expect(Roda::Project::Bin::Generators::Migration).to have_received(:new).with(
          args: ["CreateAdmin_UserProfiles", "bio:text"]
        )
      end
    end
  end

  describe "#model_name" do
    context "when input is snake_case (simple)" do
      let(:args) { ["user_profile"] }

      it "camelizes the model name" do
        expect(generator.model_name).to eq("UserProfile")
      end
    end

    context "when input is nested with '/'" do
      let(:args) { ["admin/user_profile"] }

      it "returns the fully-qualified class name" do
        expect(generator.model_name).to eq("Admin::UserProfile")
      end
    end
  end

  describe "#qualified_class_name" do
    context "with a simple name" do
      let(:args) { ["product"] }

      it "returns camelized name" do
        expect(generator.qualified_class_name).to eq("Product")
      end
    end

    context "with a nested name" do
      let(:args) { ["one/two/three"] }

      it "returns double-colon separated camelized segments" do
        expect(generator.qualified_class_name).to eq("One::Two::Three")
      end
    end
  end

  describe "#flat_class_name" do
    context "with a simple name" do
      let(:args) { ["order"] }

      it "returns camelized name" do
        expect(generator.flat_class_name).to eq("Order")
      end
    end

    context "with a nested name" do
      let(:args) { ["admin/user_profile"] }

      it "joins camelized segments without separator" do
        expect(generator.flat_class_name).to eq("AdminUserProfile")
      end
    end
  end

  describe "#table_name" do
    context "with a simple name" do
      let(:args) { ["product_category"] }

      it "returns underscored and pluralized name" do
        expect(generator.table_name).to eq("product_categories")
      end
    end

    context "with a nested name" do
      let(:args) { ["one/two/three"] }

      it "joins all segments with underscore and pluralizes" do
        expect(generator.table_name).to eq("one_two_threes")
      end
    end

    context "with a nested snake_case segment" do
      let(:args) { ["admin/user_profile"] }

      it "produces correct table name" do
        expect(generator.table_name).to eq("admin_user_profiles")
      end
    end
  end

  describe "#migration_name" do
    context "with a simple name" do
      let(:args) { ["product_category"] }

      it "builds migration name with 'Create' prefix and pluralized flat class name" do
        expect(generator.migration_name).to eq("CreateProductCategories")
      end
    end

    context "with a nested name" do
      let(:args) { ["one/two/three"] }

      it "builds migration name from all segments" do
        expect(generator.migration_name).to eq("CreateOne_Two_Threes")
      end
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

  describe "#code" do
    context "with a simple model name" do
      let(:args) { ["user"] }

      it "generates a plain class without Sequel::Model" do
        expect(generator.code).to eq("class User\nend\n")
      end
    end

    context "with one namespace level (admin/user)" do
      let(:args) { ["admin/user"] }

      it "wraps class in a module and passes table name to Sequel::Model" do
        code = generator.code
        expect(code).to include("module Admin")
        expect(code).to include("class User < Sequel::Model(:admin_users)")
        expect(code.scan("end").length).to eq(2)
      end
    end

    context "with two namespace levels (one/two/three)" do
      let(:args) { ["one/two/three"] }

      it "wraps class in two nested modules" do
        code = generator.code
        expect(code).to include("module One")
        expect(code).to include("module Two")
        expect(code).to include("class Three < Sequel::Model(:one_two_threes)")
        expect(code.scan("end").length).to eq(3)
      end

      it "has correct two-space indentation" do
        code = generator.code
        expect(code).to include("  module Two")
        expect(code).to include("    class Three")
      end
    end
  end

  describe "#spec_code" do
    context "with a simple model name" do
      let(:args) { ["user"] }

      it "uses two levels of ../  to reach spec/" do
        # file is at spec/app/models/user_spec.rb => ../../spec_helper
        expect(generator.spec_code).to include("require_relative \"../../spec_helper\"")
        expect(generator.spec_code).to include("describe User do")
      end
    end

    context "with one namespace level (admin/user)" do
      let(:args) { ["admin/user"] }

      it "uses three levels of ../ to reach spec/" do
        # file is at spec/app/models/admin/user_spec.rb => ../../../spec_helper
        expect(generator.spec_code).to include("require_relative \"../../../spec_helper\"")
        expect(generator.spec_code).to include("describe Admin::User do")
      end
    end

    context "with two namespace levels (one/two/three)" do
      let(:args) { ["one/two/three"] }

      it "uses four levels of ../ to reach spec/" do
        # file is at spec/app/models/one/two/three_spec.rb => ../../../../spec_helper
        expect(generator.spec_code).to include("require_relative \"../../../../spec_helper\"")
        expect(generator.spec_code).to include("describe One::Two::Three do")
      end
    end
  end

  describe "single-letter namespace segments (a/b/cu)" do
    let(:args) { ["a/b/cu", "oi:integer", "tchal:integer"] }
    let(:migration_instance) { instance_double(Roda::Project::Bin::Generators::Migration) }

    before do
      allow(Roda::Project::Bin::Generators::Migration).to receive(:new).and_return(migration_instance)
      allow(migration_instance).to receive(:call)
    end

    it "produces the correct table name a_b_cus" do
      expect(generator.table_name).to eq("a_b_cus")
    end

    it "produces the correct migration name that underscores to create_a_b_cus" do
      expect(generator.migration_name).to eq("CreateA_B_Cus")
    end

    it "generates model code with correct table name and two-space indentation" do
      code = generator.code
      expect(code).to eq("module A\n  module B\n    class Cu < Sequel::Model(:a_b_cus)\n    end\n  end\nend\n")
    end

    it "calls Migration with the correct args" do
      generator.call
      expect(Roda::Project::Bin::Generators::Migration).to have_received(:new).with(
        args: ["CreateA_B_Cus", "oi:integer", "tchal:integer"]
      )
    end
  end
end
