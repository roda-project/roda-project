# frozen_string_literal: true

require "tty-file"
require 'fileutils'
require "tty-reader"
require "pastel"
require_relative "project/version"
require_relative "project/context"
require_relative "project/helpers/input"
require_relative "project/helpers/template"
require_relative "project/cli"

module Roda
  module Project
    class Error < StandardError; end

    API = 1
    Fullstack = 2
    SQLite = 1
    PostgreSQL = 2
    MySQL = 3
  end
end
