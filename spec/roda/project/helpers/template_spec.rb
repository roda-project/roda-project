# frozen_string_literal: true

require "fileutils"
require "tty-file"

RSpec.describe Roda::Project::Helpers::Template do
  let(:dummy_class) do
    Class.new do
      include Roda::Project::Helpers::Template

      attr_reader :context

      def initialize(context)
        @context = context
      end
    end
  end

  let(:project_name) { "my_roda_app" }
  let(:mock_context) { instance_double("Roda::Project::MainContext", project_name: project_name) }
  let(:instance) { dummy_class.new(mock_context) }

  let(:type) { "base" }
  let(:path) { "scaffold" }
  let(:project_root) { File.expand_path("../../../../", __dir__) }
  let(:source_base_path) { File.join(project_root, "lib", "roda", "project", "templates") }
  let(:source_dir) { File.join(source_base_path, type, path) }
  let(:destination_dir) { "#{project_name}/#{path}" }

  let(:source_file_path) { File.join(source_base_path, type, path) }
  let(:destination_file_path) { "#{project_name}/#{path}" }

  describe "#erb_cp_dir" do
    it "calls TTY::File.copy_directory with correct arguments" do
      expect(TTY::File).to receive(:copy_directory).with(
        source_dir,
        destination_dir,
        context: mock_context
      )
      instance.erb_cp_dir(type, path)
    end
  end

  describe "#erb_cp_file" do
    let(:path) { "Gemfile.erb" }

    it "calls TTY::File.copy_file with correct arguments" do
      expect(TTY::File).to receive(:copy_file).with(
        source_file_path,
        destination_file_path,
        context: mock_context
      )
      instance.erb_cp_file(type, path)
    end
  end

  describe "#cp_dir" do
    it "calls FileUtils.cp_r with correct arguments" do
      expect(FileUtils).to receive(:cp_r).with(
        source_dir,
        destination_dir
      )
      instance.cp_dir(type, path)
    end
  end

  describe "#cp_file" do
    let(:path) { "README.md" }
    let(:file_content) { "This is a test README." }

    before do
      allow(File).to receive(:read).with(source_file_path).and_return(file_content)
    end

    it "reads from the source file and writes to the destination file" do
      expect(File).to receive(:read).with(source_file_path)
      expect(File).to receive(:write).with(destination_file_path, file_content)
      instance.cp_file(type, path)
    end
  end
end
