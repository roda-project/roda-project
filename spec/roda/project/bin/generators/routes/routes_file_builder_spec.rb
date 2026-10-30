# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/routes/routes_file_builder"
require "roda/project/bin/generators/routes/route"

RSpec.describe Roda::Project::Bin::Generators::Routes::RoutesFileBuilder do
  def build_route(route_str)
    Roda::Project::Bin::Generators::Routes::Route.parse(route_str)
  end

  subject(:content) do
    described_class.new(project_name: "Demo", branch_name: branch_name, routes: routes, view_mode: view_mode).content
  end

  let(:branch_name) { "users" }
  let(:routes) { [build_route("get:index"), build_route("post:create")] }
  let(:view_mode) { :none }

  it "wraps the routes in the project class and hash_branch" do
    expect(content).to include("class Demo")
    expect(content).to include('hash_branch "users" do |r|')
    expect(content).to include('r.get "index" do')
    expect(content).to include('r.post "create" do')
  end

  it "does not render view lines when views are disabled" do
    expect(content).not_to include("view('index')")
    expect(content).not_to include("inertia(")
  end

  context "with erb views" do
    let(:view_mode) { :erb }

    it "renders the view line for get routes only" do
      expect(content).to include("view('index')")
      expect(content).not_to include("view('create')")
    end

    context "when the route has no name" do
      let(:routes) { [build_route("get")] }

      it "defaults the view name to index" do
        expect(content).to include("view('index')")
      end
    end
  end

  context "with inertia views" do
    let(:view_mode) { :inertia }

    it "renders the inertia path for get routes only" do
      expect(content).to include("inertia('users/Index')")
      expect(content).not_to include("inertia('users/Create')")
    end
  end

  context "with a nested branch" do
    let(:branch_name) { "admin/users" }

    it "renders a namespaced hash_branch header" do
      expect(content).to include('hash_branch :admin, "users" do |r|')
    end
  end

  context "with a deeply nested branch" do
    let(:branch_name) { "a/b/c" }

    it "renders a namespaced hash_branch header" do
      expect(content).to include('hash_branch :"a/b", "c" do |r|')
    end
  end
end
