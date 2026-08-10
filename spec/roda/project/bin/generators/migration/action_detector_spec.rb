# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/migration/action_detector"

RSpec.describe Roda::Project::Bin::Generators::Migration::ActionDetector do
  describe "#detect" do
    context "when migration name starts with Create" do
      it "detects :create_table action and pluralized table name" do
        result = described_class.new("CreateProducts").detect
        expect(result[:action]).to eq(:create_table)
        expect(result[:table_name]).to eq("products")

        result = described_class.new("create_users").detect
        expect(result[:action]).to eq(:create_table)
        expect(result[:table_name]).to eq("users")
      end
    end

    context "when migration name matches Add...To..." do
      it "detects :add_columns action and target table name" do
        result = described_class.new("AddCategoryToProducts").detect
        expect(result[:action]).to eq(:add_columns)
        expect(result[:table_name]).to eq("products")

        result = described_class.new("add_details_to_users").detect
        expect(result[:action]).to eq(:add_columns)
        expect(result[:table_name]).to eq("users")
      end
    end

    context "when migration name matches Remove...From..." do
      it "detects :drop_columns action and target table name" do
        result = described_class.new("RemoveUnusedFieldsFromProducts").detect
        expect(result[:action]).to eq(:drop_columns)
        expect(result[:table_name]).to eq("products")

        result = described_class.new("remove_code_from_users").detect
        expect(result[:action]).to eq(:drop_columns)
        expect(result[:table_name]).to eq("users")
      end
    end

    context "when migration name matches CreateJoinTable or includes JoinTable" do
      it "detects :create_join_table action and tables from class name or args" do
        result = described_class.new("CreateJoinTableUsersProperties", args: ["user", "property"]).detect
        expect(result[:action]).to eq(:create_join_table)
        expect(result[:tables]).to eq([["user_id", "users"], ["property_id", "properties"]])

        result = described_class.new("JoinTableCategoriesPosts").detect
        expect(result[:action]).to eq(:create_join_table)
        expect(result[:tables]).to eq([["category_id", "categories"], ["post_id", "posts"]])
      end
    end

    context "when migration name does not match standard patterns" do
      it "detects :generic action with nil table_name" do
        result = described_class.new("CustomMigration").detect
        expect(result[:action]).to eq(:generic)
        expect(result[:table_name]).to be_nil
      end
    end
  end
end
