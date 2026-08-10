# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/migration"
require "tmpdir"
require "fileutils"

RSpec.describe Roda::Project::Bin::Generators::Migration do
  let(:args) { ["custom_migration"] }
  let(:generator) { described_class.new(args: args) }
  let(:tmp_dir) { Dir.mktmpdir }

  before do
    allow(generator).to receive(:migrations_path).and_return(tmp_dir)
  end

  after do
    FileUtils.rm_rf(tmp_dir)
  end

  describe "#call" do
    context "when migration_name is missing" do
      let(:args) { [] }

      it "prints usage and exits with status 1" do
        expect { generator.call }.to output(/Usage: bin\/roda g migration your_migration_name/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when migration_name is empty string" do
      let(:args) { [""] }

      it "prints usage and exits with status 1" do
        expect { generator.call }.to output(/Usage: bin\/roda g migration your_migration_name/).to_stdout
          .and raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
      end
    end

    context "when migration_name is present" do
      context "when generic migration" do
        let(:args) { ["custom_migration"] }

        it "creates generic migration file with up and down blocks" do
          expect { generator.call }.to output(/created migration/).to_stdout

          files = Dir.glob(File.join(tmp_dir, "*.rb"))
          expect(files.size).to eq(1)
          expect(File.basename(files.first)).to eq("001_custom_migration.rb")

          content = File.read(files.first)
          expect(content).to include("Sequel.migration do")
          expect(content).to include("up do")
          expect(content).to include("down do")
        end
      end

      context "when Rule 1.1: CreateProducts name:string price:decimal{10.2}" do
        let(:args) { ["CreateProducts", "name:string", "price:decimal{10.2}"] }

        it "generates create_table migration DSL" do
          expect { generator.call }.to output(/created migration/).to_stdout

          files = Dir.glob(File.join(tmp_dir, "*.rb"))
          expect(File.basename(files.first)).to eq("001_create_products.rb")

          content = File.read(files.first)
          expect(content).to include("create_table(:products) do")
          expect(content).to include("primary_key :id")
          expect(content).to include("String :name")
          expect(content).to include("BigDecimal :price, size: [10, 2]")
          expect(content).to include("DateTime :created_at")
          expect(content).to include("DateTime :updated_at")
        end
      end

      context "when Rule 1.2: AddCategoryToProducts category:references views_count:integer:index" do
        let(:args) { ["AddCategoryToProducts", "category:references", "views_count:integer:index"] }

        it "generates alter_table migration DSL with add_foreign_key, add_column, add_index" do
          expect { generator.call }.to output(/created migration/).to_stdout

          files = Dir.glob(File.join(tmp_dir, "*.rb"))
          expect(File.basename(files.first)).to eq("001_add_category_to_products.rb")

          content = File.read(files.first)
          expect(content).to include("alter_table(:products) do")
          expect(content).to include("add_foreign_key :category_id, :categories")
          expect(content).to include("add_column :views_count, Integer")
          expect(content).to include("add_index :views_count")
        end
      end

      context "when Rule 1.3: RemoveUnusedFieldsFromProducts legacy_code:string details:text" do
        let(:args) { ["RemoveUnusedFieldsFromProducts", "legacy_code:string", "details:text"] }

        it "generates alter_table migration DSL with drop_column" do
          expect { generator.call }.to output(/created migration/).to_stdout

          files = Dir.glob(File.join(tmp_dir, "*.rb"))
          expect(File.basename(files.first)).to eq("001_remove_unused_fields_from_products.rb")

          content = File.read(files.first)
          expect(content).to include("alter_table(:products) do")
          expect(content).to include("drop_column :legacy_code")
          expect(content).to include("drop_column :details")
        end
      end

      context "when Rule 1.4: CreateJoinTableUsersProperties user property" do
        let(:args) { ["CreateJoinTableUsersProperties", "user", "property"] }

        it "generates create_join_table migration DSL" do
          expect { generator.call }.to output(/created migration/).to_stdout

          files = Dir.glob(File.join(tmp_dir, "*.rb"))
          expect(File.basename(files.first)).to eq("001_create_join_table_users_properties.rb")

          content = File.read(files.first)
          expect(content).to include("create_join_table(user_id: :users, property_id: :properties)")
        end
      end

      context "when existing migration numbers are present" do
        before do
          FileUtils.touch(File.join(tmp_dir, "001_initial.rb"))
          FileUtils.touch(File.join(tmp_dir, "002_add_something.rb"))
        end

        it "creates the migration with the next sequence number" do
          expect { generator.call }.to output(/created migration/).to_stdout

          files = Dir.glob(File.join(tmp_dir, "*.rb")).sort
          expect(files.size).to eq(3)
          expect(File.basename(files.last)).to eq("003_custom_migration.rb")
        end
      end
    end
  end
end
