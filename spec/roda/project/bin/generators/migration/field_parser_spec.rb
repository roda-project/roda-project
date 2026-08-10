# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/migration/field_parser"

RSpec.describe Roda::Project::Bin::Generators::Migration::FieldParser do
  describe "#parse" do
    it "parses simple name and type" do
      fields = described_class.new(["name:string", "age:integer"]).parse
      expect(fields.size).to eq(2)

      expect(fields[0][:name]).to eq("name")
      expect(fields[0][:type]).to eq("String")

      expect(fields[1][:name]).to eq("age")
      expect(fields[1][:type]).to eq("Integer")
    end

    it "parses text type with text: true option" do
      fields = described_class.new(["details:text"]).parse
      expect(fields[0][:name]).to eq("details")
      expect(fields[0][:type]).to eq("String")
      expect(fields[0][:options][:text]).to eq(true)
    end

    it "parses decimal with precision and scale modifier" do
      fields = described_class.new(["price:decimal{10.2}"]).parse
      expect(fields[0][:name]).to eq("price")
      expect(fields[0][:type]).to eq("BigDecimal")
      expect(fields[0][:options][:size]).to eq([10, 2])
    end

    it "parses string with limit modifier" do
      fields = described_class.new(["code:string{10}"]).parse
      expect(fields[0][:name]).to eq("code")
      expect(fields[0][:type]).to eq("String")
      expect(fields[0][:options][:size]).to eq(10)
    end

    it "parses index and unique index modifiers" do
      fields = described_class.new(["email:string:uniq", "status:string:index"]).parse
      expect(fields[0][:index]).to eq(:unique)
      expect(fields[1][:index]).to eq(true)
    end

    it "parses standard references" do
      fields = described_class.new(["category:references"]).parse
      expect(fields[0][:is_reference]).to eq(true)
      expect(fields[0][:name]).to eq("category_id")
      expect(fields[0][:target_table]).to eq("categories")
      expect(fields[0][:index]).to eq(true)
    end

    it "parses polymorphic references" do
      fields = described_class.new(["imageable:references{polymorphic}"]).parse
      expect(fields.size).to eq(2)
      expect(fields[0][:name]).to eq("imageable_id")
      expect(fields[0][:type]).to eq("Bignum")
      expect(fields[1][:name]).to eq("imageable_type")
      expect(fields[1][:type]).to eq("String")
      expect(fields[0][:composite_index]).to eq(["imageable_type", "imageable_id"])
    end
  end
end
