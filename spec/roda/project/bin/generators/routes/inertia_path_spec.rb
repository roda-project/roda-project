# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/routes/inertia_path"

RSpec.describe Roda::Project::Bin::Generators::Routes::InertiaPath do
  subject(:path) { described_class.new(branch_name, name) }

  context "with a simple branch and route name" do
    let(:branch_name) { "users" }
    let(:name) { "name" }

    it "builds the view path" do
      expect(path.view_path).to eq("users/Name")
    end

    it "builds the component name" do
      expect(path.component_name).to eq("Name")
    end

    it "builds the display path" do
      expect(path.display_path).to eq("users/name")
    end

    it "imports Layout from the views root" do
      expect(path.layout_import_path).to eq("../../components/Layout")
    end
  end

  context "with a nested branch" do
    let(:branch_name) { "admin/users" }
    let(:name) { "list" }

    it "builds the view path" do
      expect(path.view_path).to eq("admin/users/List")
    end

    it "imports Layout three levels up" do
      expect(path.layout_import_path).to eq("../../../components/Layout")
    end
  end

  context "with a deeply nested branch" do
    let(:branch_name) { "admin/users/a/b/c" }
    let(:name) { "list" }

    it "builds the view path" do
      expect(path.view_path).to eq("admin/users/a/b/c/List")
    end

    it "imports Layout six levels up" do
      expect(path.layout_import_path).to eq("../../../../../../components/Layout")
    end
  end

  context "without a route name" do
    let(:branch_name) { "users" }
    let(:name) { nil }

    it "defaults to the index view" do
      expect(path.view_path).to eq("users/Index")
      expect(path.component_name).to eq("Index")
      expect(path.display_path).to eq("users/index")
    end
  end
end
