# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

require_relative "../boot"
require "rack/test"
require "rspec"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.around(:each) do |example|
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) { example.run }
  end

  def app
    App.freeze.app
  end
end
