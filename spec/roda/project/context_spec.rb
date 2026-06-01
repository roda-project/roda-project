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

  describe "#tests=" do
    context "with a valid test framework" do
      it "sets the tests attribute" do
        context.tests = Roda::Project::RSPEC
        expect(context.tests).to eq(Roda::Project::RSPEC)
      end
    end

    context "with an invalid test framework" do
      it "raises an InvalidValue error" do
        expect { context.tests = "invalid" }.to raise_error(Roda::Project::Context::InvalidValue, "Invalid test framework option")
      end
    end
  end

  describe "#base=" do
    context "with a valid base option" do
      it "sets the base attribute" do
        context.base = Roda::Project::FULLSTACK
        expect(context.base).to eq(Roda::Project::FULLSTACK)
      end
    end

    context "with an invalid base option" do
      it "raises an InvalidValue error" do
        expect { context.base = "invalid" }.to raise_error(Roda::Project::Context::InvalidValue, "Invalid project option")
      end
    end
  end

  describe "#rodauth=" do
    context "with true" do
      it "sets rodauth to true" do
        context.rodauth = true
        expect(context.rodauth).to be true
      end
    end

    context "with false" do
      it "sets rodauth to false" do
        context.rodauth = false
        expect(context.rodauth).to be false
      end
    end

    context "with an invalid value" do
      it "sets rodauth to false" do
        context.rodauth = "invalid"
        expect(context.rodauth).to be false
      end
    end
  end

  describe "#database=" do
    context "with true" do
      it "sets database to true" do
        context.database = true
        expect(context.database).to be true
      end
    end

    context "with false" do
      it "sets database to false" do
        context.database = false
        expect(context.database).to be false
      end
    end

    context "with an invalid value" do
      it "sets database to false" do
        context.database = "invalid"
        expect(context.database).to be false
      end
    end
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

    context "with an invalid database type" do
      it "raises an InvalidValue error" do
        expect { context.database_type = "invalid" }.to raise_error(Roda::Project::Context::InvalidValue, "Invalid database option")
      end
    end
  end

  describe "#project_name=" do
    context "with a valid project name" do
      it "sets the project_name attribute" do
        context.project_name = "MyProject_123"
        expect(context.project_name).to eq("MyProject_123")
      end
    end

    context "with an invalid project name" do
      it "raises an InvalidValue error for starting with a number" do
        expect { context.project_name = "1MyProject" }.to raise_error(Roda::Project::Context::InvalidValue, "Project name must start with a letter and contains only letters, numbers and _")
      end

      it "raises an InvalidValue error for containing special characters" do
        expect { context.project_name = "My-Project" }.to raise_error(Roda::Project::Context::InvalidValue, "Project name must start with a letter and contains only letters, numbers and _")
      end
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

  describe "#minimal?" do
    context "when base is API" do
      before { context.base = Roda::Project::MINIMAL }
      it { is_expected.to be_minimal }
    end

    context "when base is not API" do
      before { context.base = Roda::Project::FULLSTACK }
      it { is_expected.not_to be_minimal }
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
