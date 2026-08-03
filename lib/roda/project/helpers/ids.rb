class Roda
  module Project
    module Helpers
      module Ids
        def fullstack_id = Roda::Project::FULLSTACK
        def api_id = Roda::Project::API
        def minimal_id = Roda::Project::MINIMAL
        def mysql_id = Roda::Project::MYSQL
        def sqlite_id = Roda::Project::SQLITE
        def postgresql_id = Roda::Project::POSTGRESQL
        def rspec_id = Roda::Project::RSPEC
        def minitest_id = Roda::Project::MINITEST

        def id_to_string(id, type)
          const =
            case type
            when :base
              case id
              when fullstack_id
                "FULLSTACK"
              when api_id
                "API"
              when minimal_id
                "MINIMAL"
              end
            when :database
              case id
              when mysql_id
                "MYSQL"
              when sqlite_id
                "SQLITE"
              when postgresql_id
                "POSTGRESQL"
              end
            when :tests
              case id
              when rspec_id
                "RSPEC"
              when minitest_id
                "MINITEST"
              end
            end

          "Roda::Project::" << const
        end
      end
    end
  end
end
