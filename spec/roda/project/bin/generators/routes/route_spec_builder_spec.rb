# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/routes/route_spec_builder"
require "roda/project/bin/generators/routes/route"

RSpec.describe Roda::Project::Bin::Generators::Routes::RouteSpecBuilder do
  def build_route(route_str)
    Roda::Project::Bin::Generators::Routes::Route.parse(route_str)
  end

  subject(:content) { described_class.new(branch_name: branch_name, routes: routes).content }

  context "with a simple branch" do
    let(:branch_name) { "users" }
    let(:routes) { [build_route("get:index"), build_route("post:create")] }

    it "requires the spec helper from the spec/app/routes depth" do
      expect(content).to include('require_relative "../../spec_helper"')
    end

    it "renders a describe block with a request per route" do
      expect(content).to include('describe "Routes for users" do')
      expect(content).to include('it "responds to GET /users/index" do')
      expect(content).to include('get "/users/index"')
      expect(content).to include('it "responds to POST /users/create" do')
      expect(content).to include('post "/users/create"')
    end

    context "when a route has no name" do
      let(:routes) { [build_route("get")] }

      it "renders the branch root path" do
        expect(content).to include('it "responds to GET /users" do')
        expect(content).to include('get "/users"')
      end
    end
  end

  context "with a nested branch" do
    let(:branch_name) { "admin/users" }
    let(:routes) { [build_route("get:list")] }

    it "requires the spec helper one level deeper" do
      expect(content).to include('require_relative "../../../spec_helper"')
    end
  end
end
