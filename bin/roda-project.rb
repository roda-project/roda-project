#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/roda/project/commands'

Dry::CLI.new(Roda::Project::Commands).call
