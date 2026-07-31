require 'spec_helper'
require 'roda/project/helpers/ids'

RSpec.describe Roda::Project::Helpers::Ids do
  let(:dummy_class) do
    Class.new do
      include Roda::Project::Helpers::Ids
    end
  end

  let(:instance) { dummy_class.new }

  describe '#id_to_string' do
    context 'when type is :base' do
      it 'returns Roda::Project::FULLSTACK for fullstack_id' do
        expect(instance.id_to_string(instance.fullstack_id, :base)).to eq('Roda::Project::FULLSTACK')
      end

      it 'returns Roda::Project::API for api_id' do
        expect(instance.id_to_string(instance.api_id, :base)).to eq('Roda::Project::API')
      end

      it 'returns Roda::Project::MINIMAL for minimal_id' do
        expect(instance.id_to_string(instance.minimal_id, :base)).to eq('Roda::Project::MINIMAL')
      end
    end

    context 'when type is :database' do
      it 'returns Roda::Project::MYSQL for mysql_id' do
        expect(instance.id_to_string(instance.mysql_id, :database)).to eq('Roda::Project::MYSQL')
      end

      it 'returns Roda::Project::SQLITE for sqlite_id' do
        expect(instance.id_to_string(instance.sqlite_id, :database)).to eq('Roda::Project::SQLITE')
      end

      it 'returns Roda::Project::POSTGRESQL for postgresql_id' do
        expect(instance.id_to_string(instance.postgresql_id, :database)).to eq('Roda::Project::POSTGRESQL')
      end
    end

    context 'when type is :tests' do
      it 'returns Roda::Project::RSPEC for rspec_id' do
        expect(instance.id_to_string(instance.rspec_id, :tests)).to eq('Roda::Project::RSPEC')
      end

      it 'returns Roda::Project::MINITEST for minitest_id' do
        expect(instance.id_to_string(instance.minitest_id, :tests)).to eq('Roda::Project::MINITEST')
      end
    end
  end
end
