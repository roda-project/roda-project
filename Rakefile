# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard:fix]

desc "update rspec snapshots"
task "spec:update_snapshots" do
  system("UPDATE_SNAPSHOTS=true bundle exec rspec")
end
