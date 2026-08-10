# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/migration/code_builder"

RSpec.describe Roda::Project::Bin::Generators::Migration::CodeBuilder do
  describe "#build" do
    context "when action is :create_table" do
      it "generates create_table migration with primary key and timestamps" do
        detection = { action: :create_table, table_name: "products" }
        fields = [
          { name: "name", type: "String", options: {}, index: false },
          { name: "price", type: "BigDecimal", options: { size: [10, 2] }, index: false }
        ]

        code = described_class.new(detection: detection, fields: fields).build
        expect(code).to include("Sequel.migration do")
        expect(code).to include("change do")
        expect(code).to include("create_table(:products) do")
        expect(code).to include("primary_key :id")
        expect(code).to include("String :name")
        expect(code).to include("BigDecimal :price, size: [10, 2]")
        expect(code).to include("DateTime :created_at")
        expect(code).to include("DateTime :updated_at")
      end

      it "includes unique and standard index declarations inside create_table" do
        detection = { action: :create_table, table_name: "accounts" }
        fields = [
          { name: "email", type: "String", options: {}, index: :unique },
          { name: "status", type: "String", options: {}, index: true }
        ]

        code = described_class.new(detection: detection, fields: fields).build
        expect(code).to include("index :email, unique: true")
        expect(code).to include("index :status")
      end
    end

    context "when action is :add_columns" do
      it "generates alter_table migration with add_column and add_foreign_key" do
        detection = { action: :add_columns, table_name: "products" }
        fields = [
          { name: "category_id", is_reference: true, target_table: "categories", index: true, options: {} },
          { name: "views_count", type: "Integer", options: {}, index: true }
        ]

        code = described_class.new(detection: detection, fields: fields).build
        expect(code).to include("alter_table(:products) do")
        expect(code).to include("add_foreign_key :category_id, :categories")
        expect(code).to include("add_column :views_count, Integer")
        expect(code).to include("add_index :views_count")
      end

      it "handles polymorphic references in alter_table" do
        detection = { action: :add_columns, table_name: "photos" }
        fields = [
          { name: "imageable_id", type: "Bignum", options: {}, index: false, composite_index: ["imageable_type", "imageable_id"] },
          { name: "imageable_type", type: "String", options: {}, index: false }
        ]

        code = described_class.new(detection: detection, fields: fields).build
        expect(code).to include("add_column :imageable_id, Bignum")
        expect(code).to include("add_column :imageable_type, String")
        expect(code).to include("add_index [:imageable_type, :imageable_id]")
      end
    end

    context "when action is :drop_columns" do
      it "generates alter_table migration with drop_column" do
        detection = { action: :drop_columns, table_name: "products" }
        fields = [
          { name: "legacy_code", type: "String", options: {}, index: false },
          { name: "details", type: "String", options: { text: true }, index: false }
        ]

        code = described_class.new(detection: detection, fields: fields).build
        expect(code).to include("alter_table(:products) do")
        expect(code).to include("drop_column :legacy_code")
        expect(code).to include("drop_column :details")
      end
    end

    context "when action is :create_join_table" do
      it "generates create_join_table migration" do
        detection = {
          action: :create_join_table,
          tables: [["user_id", "users"], ["property_id", "properties"]]
        }

        code = described_class.new(detection: detection, fields: []).build
        expect(code).to include("create_join_table(user_id: :users, property_id: :properties)")
      end
    end

    context "when action is :generic" do
      it "generates generic up and down blocks" do
        detection = { action: :generic, table_name: nil }

        code = described_class.new(detection: detection, fields: []).build
        expect(code).to include("up do")
        expect(code).to include("down do")
      end
    end
  end
end
