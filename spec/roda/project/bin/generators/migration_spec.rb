# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/migration"
require "tmpdir"
require "fileutils"

RSpec.describe Roda::Project::Bin::Generators::Migration do
  let(:args) { ["create_users"] }
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
      context "when migrations_path does not exist" do
        let(:tmp_dir) { File.join(Dir.tmpdir, "non_existent_migrations_#{Time.now.to_i}") }

        after do
          FileUtils.rm_rf(tmp_dir)
        end

        it "creates the directory" do
          expect(File.directory?(tmp_dir)).to be false
          expect { generator.call }.to output(/created migration/).to_stdout
          expect(File.directory?(tmp_dir)).to be true
        end

        it "creates the first migration file with correct content" do
          expect { generator.call }.to output(/created migration/).to_stdout

          files = Dir.glob(File.join(tmp_dir, "*.rb"))
          expect(files.size).to eq(1)
          expect(File.basename(files.first)).to eq("001_create_users.rb")

          content = File.read(files.first)
          expect(content).to include("Sequel.migration do")
          expect(content).to include("up do")
          expect(content).to include("down do")
        end
      end

      context "when migrations exist" do
        before do
          FileUtils.touch(File.join(tmp_dir, "001_initial.rb"))
          FileUtils.touch(File.join(tmp_dir, "002_add_something.rb"))
        end

        it "creates the migration with the next sequence number" do
          expect { generator.call }.to output(/created migration/).to_stdout

          files = Dir.glob(File.join(tmp_dir, "*.rb")).sort
          expect(files.size).to eq(3)
          expect(File.basename(files.last)).to eq("003_create_users.rb")
        end
      end

      context "when existing migration numbers are not contiguous" do
        before do
          FileUtils.touch(File.join(tmp_dir, "010_initial.rb"))
        end

        it "creates the migration with the max number + 1" do
          expect { generator.call }.to output(/created migration/).to_stdout

          files = Dir.glob(File.join(tmp_dir, "*.rb")).sort
          expect(files.size).to eq(2)
          expect(File.basename(files.last)).to eq("011_create_users.rb")
        end
      end
    end
  end
end
