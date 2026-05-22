# frozen_string_literal: true

require "tty-file"
require "fileutils"
require "tty-reader"
require "pastel"
require_relative "project/version"
require_relative "project/helpers/ids"
require_relative "project/context"
require_relative "project/helpers/input"
require_relative "project/helpers/template"
require_relative "project/cli"

module Roda
  module Project
    class Error < StandardError; end

    FULLSTACK = 1
    API = 2
    SQLITE = 1
    POSTGRESQL = 2
    MYSQL = 3
    RSPEC = 1
    MINITEST = 2
  end
end
