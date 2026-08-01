require "./lib/roda/project.rb"
c = Roda::Project::MainContext.new
c.project_name = 'test'
c.base = Roda::Project::FULLSTACK
c.database = true
c.database_type = Roda::Project::POSTGRESQL
c.rodauth = true
c.tests = Roda::Project::RSPEC
puts c.to_s.inspect
