module Roda
  module Project
    class Context
      attr_accessor(
        :project_name,
        :base,
        :database,
        :rodauth
      )
      attr_reader :database_type, :dev_db_url, :db_gem

      def foo_bar_example
        return 'view("bar")' if fullstack?

        '{ foo: "bar" }'
      end

      def root_example
        return 'view("index")' if fullstack?

        '{ message: "#{t.hello.message}" }'
      end

      def fullstack?
        base == Roda::Project::FULLSTACK
      end

      def api?
        base == Roda::Project::API
      end

      def rodauth?
        rodauth == true
      end

      def database?
        database == true
      end

      def database_type=(val)
        @database_type = val

        if mysql?
          @dev_db_url = '"mysql2://user:password@localhost/app_#{environment}"'
          @db_gem = "mysql2"
        elsif postgresql?
          @dev_db_url = '"postgres://user:password@localhost:5432/app_#{environment}"'
          @db_gem = "pg"
        else
          @dev_db_url = '"sqlite://db/#{environment}.db"'
          @db_gem = "sqlite3"
        end
      end

      def mysql?
        return false unless database?

        database_type == Roda::Project::MYSQL
      end

      def postgresql?
        return false unless database?

        database_type == Roda::Project::POSTGRESQL
      end

      def sqlite?
        return false unless database?

        database_type == Roda::Project::SQLITE
      end
    end
  end
end
