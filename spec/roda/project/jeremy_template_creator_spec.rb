# frozen_string_literal: true

require "spec_helper"

RSpec.describe Roda::Project::JeremyTemplateCreator do
  let(:context) { instance_double(Roda::Project::MainContext, project_name: "my_cool_app") }
  let(:pastel) { double("Pastel", green: "green_text") }
  let(:creator) { described_class.new(context: context, pastel: pastel) }

  describe "#call" do
    let(:repo_url) { "https://github.com/jeremyevans/roda-sequel-stack" }
    let(:git_dir) { "my_cool_app/.git" }
    let(:setup_command) { "cd my_cool_app && rake setup[MyCoolApp]" }

    before do
      allow(creator).to receive(:puts)
      allow(creator).to receive(:system).with("git clone --depth 1 #{repo_url} my_cool_app").and_return(true)
      allow(creator).to receive(:system).with(setup_command).and_return(true)
      allow(Dir).to receive(:exist?).with(git_dir).and_return(true)
      allow(FileUtils).to receive(:rm_rf).with(git_dir)
      allow(creator).to receive(:action_success_message)
    end

    it "clones the repository with git" do
      expect(creator).to receive(:system).with("git clone --depth 1 #{repo_url} my_cool_app")
      creator.call
    end

    context "when git clone fails" do
      before do
        allow(creator).to receive(:system).with("git clone --depth 1 #{repo_url} my_cool_app").and_return(false)
      end

      it "aborts with an error message" do
        expect(creator).to receive(:abort).with("\nCould not download the template.")
        creator.call
      end
    end

    context "when .git directory exists" do
      before do
        allow(Dir).to receive(:exist?).with(git_dir).and_return(true)
      end

      it "removes the .git directory and prints cleanup message" do
        expect(FileUtils).to receive(:rm_rf).with(git_dir)
        expect(creator).to receive(:puts).with("\n* Cleaned up template git history.\n\n")
        creator.call
      end
    end

    context "when .git directory does not exist" do
      before do
        allow(Dir).to receive(:exist?).with(git_dir).and_return(false)
      end

      it "does not attempt to remove the .git directory" do
        expect(FileUtils).not_to receive(:rm_rf)
        creator.call
      end
    end

    it "outputs action success message for project creation" do
      expect(creator).to receive(:action_success_message).with("./my_cool_app")
      creator.call
    end

    it "runs the setup command using rake with camelized project name" do
      expect(creator).to receive(:system).with(setup_command)
      creator.call
    end

    it "outputs action success message for running setup command" do
      expect(creator).to receive(:action_success_message).with(setup_command, "run")
      creator.call
    end
  end
end
