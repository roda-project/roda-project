# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/routes/nested_branch_file_builder"

RSpec.describe Roda::Project::Bin::Generators::Routes::NestedBranchFileBuilder do
  subject(:content) { described_class.new(project_name: "Demo", prefix: prefix).content }

  context "with a first-level branch" do
    let(:prefix) { "admin" }

    it "renders a root hash_branch" do
      expect(content).to include("class Demo")
      expect(content).to include('hash_branch "admin" do |r| # admin branch')
      expect(content).to include("r.hash_branches(:admin) # admin/ +1 routes")
    end
  end

  context "with a nested branch" do
    let(:prefix) { "admin/users" }

    it "renders a namespaced hash_branch with its parent hash_branches call" do
      expect(content).to include('hash_branch :admin, "users" do |r| # admin/users branch')
      expect(content).to include('r.hash_branches(:"admin/users") # admin/users/ +1 routes')
    end
  end

  context "with a deeply nested branch" do
    let(:prefix) { "a/b/c" }

    it "renders a namespaced hash_branch with its parent hash_branches call" do
      expect(content).to include('hash_branch :"a/b", "c" do |r| # a/b/c branch')
      expect(content).to include('r.hash_branches(:"a/b/c") # a/b/c/ +1 routes')
    end
  end
end
