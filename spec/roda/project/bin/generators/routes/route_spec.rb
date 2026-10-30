# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/routes/route"

RSpec.describe Roda::Project::Bin::Generators::Routes::Route do
  describe ".parse" do
    it "parses a method and a name" do
      route = described_class.parse("post:create")

      expect(route.method).to eq("post")
      expect(route.name).to eq("create")
    end

    it "parses a bare valid method as a route without a name" do
      route = described_class.parse("get")

      expect(route.method).to eq("get")
      expect(route.name).to be_nil
    end

    it "falls back to get for a bare route name" do
      route = described_class.parse("index")

      expect(route.method).to eq("get")
      expect(route.name).to eq("index")
    end

    it "falls back to get for an invalid method" do
      route = described_class.parse("foo:bar")

      expect(route.method).to eq("get")
      expect(route.name).to eq("foo:bar")
    end

    it "keeps an empty route name" do
      route = described_class.parse("get:")

      expect(route.method).to eq("get")
      expect(route.name).to eq("")
    end
  end

  describe "#get?" do
    it "is true for get routes" do
      expect(described_class.parse("get:index")).to be_get
    end

    it "is false for other methods" do
      expect(described_class.parse("post:create")).not_to be_get
    end
  end
end
