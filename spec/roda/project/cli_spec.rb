# frozen_string_literal: true

require "pastel"
require "tty-reader"
require "tty-file"
require "fileutils"

RSpec.describe Roda::Project::CLI do
  it 'includes files from templates/base/scaffold' do
  end

  context 'when context includes database' do
    it 'includes files from templates/database' do
    end
    context 'when context includes rodauth' do
      it 'includes files from templates/rodauth' do
      end
    end
  end
  context 'when context has no database' do
  end

  context 'when context is fullstack' do
    it 'includes files from templates/front-end' do
    end
  end
end
