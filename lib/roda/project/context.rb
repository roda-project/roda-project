module Roda
  module Project
    class Context
      def fullstack?
        base == Roda::Project::Fullstack
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
          @dev_db_url ='"mysql2://user:password@localhost/app_#{environment}"'
          @db_gem = 'mysql2'
        elsif postgresql?
          @dev_db_url ='"postgres://user:password@localhost:5432/app_#{environment}"'
          @db_gem = 'pg'
        else
          @dev_db_url ='"sqlite://db/#{environment}.db"'
          @db_gem = 'sqlite3'
        end
      end

      def mysql?
        return false unless database?

        database_type == Roda::Project::MySQL
      end

      def postgresql?
        return false unless database?

        database_type == Roda::Project::PostgreSQL
      end

      def sqlite?
        return false unless database?

        database_type == Roda::Project::SQlite
      end

      attr_accessor(
        :project_name,
        :base,
        :database,
        :rodauth,
      )
      attr_reader :database_type, :dev_db_url, :db_gem
    end
  end
end
