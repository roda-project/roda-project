# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

require_relative "../boot"
require "rack/test"
require "rspec"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    App.freeze.app
  end
end
