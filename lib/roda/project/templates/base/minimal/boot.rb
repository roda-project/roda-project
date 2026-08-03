require "bundler/setup"

NOT_PRODUCTION = (ENV["RACK_ENV"] || "development") != "production"

Bundler.require

# require 'byebug' if ENV['RACK_ENV'] != 'production'

# Config file loads
loader = Zeitwerk::Loader.new
loader.collapse("#{__dir__}/services")

# [
# 'config',
# 'models',
# 'services',
# 'callbacks',
# 'actions'
# ].each do |path|
# loader.push_dir("#{__dir__}/app/#{path}")
# end
loader.setup

require "debug" if NOT_PRODUCTION

Oj.mimic_JSON

require_relative "app"
