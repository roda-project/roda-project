module Roda
  module Project
    module Helpers
      module Ids
        def fullstack_id = Roda::Project::FULLSTACK
        def mysql_id = Roda::Project::MYSQL
        def sqlite_id = Roda::Project::SQLITE
        def postgresql_id = Roda::Project::POSTGRESQL
        def api_id = Roda::Project::API
        def rspec_id = Roda::Project::RSPEC
        def minitest_id = Roda::Project::MINITEST
      end
    end
  end
end
