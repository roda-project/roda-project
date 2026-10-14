# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

require_relative "../boot"
require 'rack/test'
require "minitest/autorun"
require 'minitest/hooks/default'

class Minitest::HooksSpec
  include Rack::Test::Methods

  def app
    App.freeze.app
  end
end

class Minitest::HooksSpec
  def log
    LOGGER.level = Logger::INFO
    yield
  ensure
    LOGGER.level = Logger::FATAL
  end
end
