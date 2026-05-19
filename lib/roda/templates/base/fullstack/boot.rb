require "bundler/setup"
Bundler.require

# require 'byebug' if ENV['RACK_ENV'] != 'production'

# Config file loads
loader = Zeitwerk::Loader.new
loader.inflector.inflect("db" => "DB")
loader.push_dir("#{__dir__}/app")
loader.collapse("#{__dir__}/lib")
loader.collapse("#{__dir__}/app/models")
loader.collapse("#{__dir__}/app/services")
loader.collapse("#{__dir__}/app/config")

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
require "debug" if Config.not_production?

Oj.mimic_JSON

# Providers
Providers::DB::Conn.boot
Providers::Mailer.boot
Providers::Logger.boot

# Consts
DB = Providers::DB::Conn.get
