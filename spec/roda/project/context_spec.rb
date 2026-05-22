# frozen_string_literal: true

RSpec.describe Roda::Project::Context do
  subject(:context) { described_class.new }

  describe "attributes" do
    it { is_expected.to respond_to(:project_name) }
    it { is_expected.to respond_to(:project_name=) }
    it { is_expected.to respond_to(:base) }
    it { is_expected.to respond_to(:base=) }
    it { is_expected.to respond_to(:database) }
    it { is_expected.to respond_to(:database=) }
    it { is_expected.to respond_to(:rodauth) }
    it { is_expected.to respond_to(:rodauth=) }
    it { is_expected.to respond_to(:database_type) }
    it { is_expected.to respond_to(:dev_db_url) }
    it { is_expected.to respond_to(:db_gem) }
    it { is_expected.to respond_to(:tests) }
    it { is_expected.to respond_to(:tests=) }

    it "allows setting and getting project_name" do
      context.project_name = "MyProject"
      expect(context.project_name).to eq("MyProject")
    end
  end

  describe "#rspec?" do
    context "when tests is Roda::Project::RSPEC" do
      before { context.tests = Roda::Project::RSPEC }
      it { is_expected.to be_rspec }
    end

    context "when tests is not Roda::Project::RSPEC" do
      before { context.tests = Roda::Project::MINITEST }
      it { is_expected.not_to be_rspec }
    end
  end

  describe "#minitest?" do
    context "when tests is Roda::Project::MINITEST" do
      before { context.tests = Roda::Project::MINITEST }
      it { is_expected.to be_minitest }
    end

    context "when tests is not Roda::Project::MINITEST" do
      before { context.tests = Roda::Project::RSPEC }
      it { is_expected.not_to be_minitest }
    end
  end

  describe "#fullstack?" do
    context "when base is FULLSTACK" do
      before { context.base = Roda::Project::FULLSTACK }
      it { is_expected.to be_fullstack }
    end

    context "when base is not FULLSTACK" do
      before { context.base = Roda::Project::API }
      it { is_expected.not_to be_fullstack }
    end
  end

  describe "#api?" do
    context "when base is API" do
      before { context.base = Roda::Project::API }
      it { is_expected.to be_api }
    end

    context "when base is not API" do
      before { context.base = Roda::Project::FULLSTACK }
      it { is_expected.not_to be_api }
    end
  end

  describe "#rodauth?" do
    context "when rodauth is true" do
      before { context.rodauth = true }
      it { is_expected.to be_rodauth }
    end

    context "when rodauth is false" do
      before { context.rodauth = false }
      it { is_expected.not_to be_rodauth }
    end
  end

  describe "#database?" do
    context "when database is true" do
      before { context.database = true }
      it { is_expected.to be_database }
    end

    context "when database is false" do
      before { context.database = false }
      it { is_expected.not_to be_database }
    end
  end

  describe "#foo_bar_example" do
    context "when fullstack?" do
      before { allow(context).to receive(:fullstack?).and_return(true) }
      it "returns the fullstack example" do
        expect(context.foo_bar_example).to eq('view("bar")')
      end
    end

    context "when not fullstack?" do
      before { allow(context).to receive(:fullstack?).and_return(false) }
      it "returns the non-fullstack example" do
        expect(context.foo_bar_example).to eq('{ foo: "bar" }')
      end
    end
  end

  describe "#root_example" do
    context "when fullstack? is true" do
      before { allow(context).to receive(:fullstack?).and_return(true) }
      it "returns the rodauth fullstack example" do
        expect(context.root_example).to eq("view(\"index\")")
      end
    end

    # rubocop:disable Lint/InterpolationCheck
    context "when fullstack? is false" do
      before { allow(context).to receive(:fullstack?).and_return(false) }
      it "returns the rodauth non-fullstack example" do
        expect(context.root_example).to eq('{ message: "#{t.hello.message}" }')
      end
    end
    # rubocop:enable Lint/InterpolationCheck
  end

  describe "#database_type=" do
    context "when database_type is MYSQL" do
      before do
        context.database = true # Added this line
        context.database_type = Roda::Project::MYSQL
      end
      it "sets database_type, dev_db_url, and db_gem correctly" do
        expect(context.database_type).to eq(Roda::Project::MYSQL)
        expect(context.dev_db_url).to eq('"mysql2://user:password@localhost/app_#{environment}"')
        expect(context.db_gem).to eq("mysql2")
      end
    end

    context "when database_type is POSTGRESQL" do
      before do
        context.database = true # Added this line
        context.database_type = Roda::Project::POSTGRESQL
      end
      it "sets database_type, dev_db_url, and db_gem correctly" do
        expect(context.database_type).to eq(Roda::Project::POSTGRESQL)
        expect(context.dev_db_url).to eq('"postgres://user:password@localhost:5432/app_#{environment}"')
        expect(context.db_gem).to eq("pg")
      end
    end

    context "when database_type is SQLITE" do
      before { context.database_type = Roda::Project::SQLITE }
      it "sets database_type, dev_db_url, and db_gem correctly" do
        expect(context.database_type).to eq(Roda::Project::SQLITE)
        expect(context.dev_db_url).to eq('"sqlite://db/#{environment}.db"')
        expect(context.db_gem).to eq("sqlite3")
      end
    end
  end

  describe "#mysql?" do
    context "when database is true and database_type is MYSQL" do
      before do
        context.database = true
        context.database_type = Roda::Project::MYSQL
      end
      it { is_expected.to be_mysql }
    end

    context "when database is true but database_type is not MYSQL" do
      before do
        context.database = true
        context.database_type = Roda::Project::POSTGRESQL
      end
      it { is_expected.not_to be_mysql }
    end

    context "when database is false" do
      before do
        context.database = false
        context.database_type = Roda::Project::MYSQL
      end
      it { is_expected.not_to be_mysql }
    end
  end

  describe "#postgresql?" do
    context "when database is true and database_type is POSTGRESQL" do
      before do
        context.database = true
        context.database_type = Roda::Project::POSTGRESQL
      end
      it { is_expected.to be_postgresql }
    end

    context "when database is true but database_type is not POSTGRESQL" do
      before do
        context.database = true
        context.database_type = Roda::Project::MYSQL
      end
      it { is_expected.not_to be_postgresql }
    end

    context "when database is false" do
      before do
        context.database = false
        context.database_type = Roda::Project::POSTGRESQL
      end
      it { is_expected.not_to be_postgresql }
    end
  end

  describe "#sqlite?" do
    context "when database is true and database_type is SQLITE" do
      before do
        context.database = true
        context.database_type = Roda::Project::SQLITE
      end
      it { is_expected.to be_sqlite }
    end

    context "when database is true but database_type is not SQLITE" do
      before do
        context.database = true
        context.database_type = Roda::Project::MYSQL
      end
      it { is_expected.not_to be_sqlite }
    end

    context "when database is false" do
      before do
        context.database = false
        context.database_type = Roda::Project::SQLITE
      end
      it { is_expected.not_to be_sqlite }
    end
  end
end
