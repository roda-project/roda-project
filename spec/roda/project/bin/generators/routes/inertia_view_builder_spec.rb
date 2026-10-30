# frozen_string_literal: true

require "spec_helper"
require "roda/project/bin/generators/routes/inertia_view_builder"
require "roda/project/bin/generators/routes/inertia_path"

RSpec.describe Roda::Project::Bin::Generators::Routes::InertiaViewBuilder do
  subject(:builder) { described_class.new(path) }

  let(:path) { Roda::Project::Bin::Generators::Routes::InertiaPath.new(branch_name, name) }

  context "with a simple branch" do
    let(:branch_name) { "users" }
    let(:name) { "name" }

    describe "#component_content" do
      it "renders the component with the correct layout import" do
        expect(builder.component_content).to include("import Layout from '../../components/Layout'")
        expect(builder.component_content).to include("const Name = props => {")
        expect(builder.component_content).to include("export default Name")
      end
    end

    describe "#test_content" do
      it "renders a jest spec beside the component" do
        expect(builder.test_content).to include("import Name from './Name'")
        expect(builder.test_content).to include("describe('Name', () => {")
        expect(builder.test_content).to include("render(<Name />)")
        expect(builder.test_content).to include("screen.getByText('users/name')")
        expect(builder.test_content).to include("toBeInTheDocument()")
      end
    end
  end

  context "with a nested branch" do
    let(:branch_name) { "admin/users" }
    let(:name) { "list" }

    it "imports Layout three levels up" do
      expect(builder.component_content).to include("import Layout from '../../../components/Layout'")
    end

    it "uses the nested display path in the spec" do
      expect(builder.test_content).to include("screen.getByText('admin/users/list')")
    end
  end
end
