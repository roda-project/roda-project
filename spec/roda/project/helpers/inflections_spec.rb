# frozen_string_literal: true

require "spec_helper"
require "roda/project/helpers/inflections"

RSpec.describe Roda::Project::Helpers::Inflections do
  describe ".camelize" do
    it "converts snake_case to CamelCase" do
      expect(described_class.camelize("create_products")).to eq("CreateProducts")
      expect(described_class.camelize("user_profile")).to eq("UserProfile")
    end

    it "returns string unchanged if it already contains capital letters" do
      expect(described_class.camelize("CreateProducts")).to eq("CreateProducts")
      expect(described_class.camelize("AddCategoryToProducts")).to eq("AddCategoryToProducts")
    end
  end

  describe ".underscore" do
    it "converts CamelCase to snake_case" do
      expect(described_class.underscore("CreateProducts")).to eq("create_products")
      expect(described_class.underscore("AddCategoryToProducts")).to eq("add_category_to_products")
      expect(described_class.underscore("HTTPResponse")).to eq("http_response")
    end
  end

  describe ".pluralize" do
    it "pluralizes standard words" do
      expect(described_class.pluralize("product")).to eq("products")
      expect(described_class.pluralize("user")).to eq("users")
    end

    it "pluralizes words ending in y" do
      expect(described_class.pluralize("category")).to eq("categories")
      expect(described_class.pluralize("property")).to eq("properties")
    end

    it "pluralizes words ending in s, x, z, ch, sh" do
      expect(described_class.pluralize("box")).to eq("boxes")
      expect(described_class.pluralize("match")).to eq("matches")
    end

    it "does not double-pluralize words already ending in s" do
      expect(described_class.pluralize("products")).to eq("products")
    end
  end

  describe ".singularize" do
    it "singularizes standard plural words" do
      expect(described_class.singularize("products")).to eq("product")
      expect(described_class.singularize("users")).to eq("user")
    end

    it "singularizes words ending in ies" do
      expect(described_class.singularize("categories")).to eq("category")
      expect(described_class.singularize("properties")).to eq("property")
    end

    it "singularizes words ending in es" do
      expect(described_class.singularize("boxes")).to eq("box")
      expect(described_class.singularize("matches")).to eq("match")
    end

    it "returns non-plural word unchanged" do
      expect(described_class.singularize("product")).to eq("product")
    end
  end
end
