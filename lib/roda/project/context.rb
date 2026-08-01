module Roda
  module Project
    class Context
      include Helpers::Ids

      class InvalidValue < Roda::Project::Error; end
      VALID_PROJECT_NAME_REGEX = /^[a-zA-Z][a-zA-Z0-9_]*$/

      attr_reader(
        :tests,
        :rodauth,
        :database,
        :database_type,
        :default_db_url,
        :db_gem,
        :project_name,
        :base
      )

      def to_ruby_code
        <<~RUBY
context = Roda::Project::Context.new
context.project_name = "#{project_name}"
context.base = #{id_to_string(base, :base)}
context.database = #{database}
context.database_type = #{id_to_string(database_type, :database)}
context.rodauth = #{rodauth}
context.tests = #{id_to_string(tests, :tests)}
        RUBY
      end

      def tests=(val)
        if ![minitest_id, rspec_id].include?(val)
          raise InvalidValue, "Invalid test framework option"
        end

        @tests = val
      end

      def base=(val)
        if ![fullstack_id, api_id, minimal_id].include?(val)
          raise InvalidValue, "Invalid project option"
        end

        @base = val
      end

      def rodauth=(val)
        val = false if ![true, false].include?(val)

        @rodauth = val
      end

      def database=(val)
        val = false if ![true, false].include?(val)

        @database = val
      end

      # rubocop:disable Lint/InterpolationCheck
      def database_type=(val)
        if ![mysql_id, postgresql_id, sqlite_id].include?(val)
          raise InvalidValue, "Invalid database option"
        end

        @database_type = val

        if mysql?
          @default_db_url = '"mysql2://user:password@localhost/app_#{environment}"'
          @db_gem = "mysql2"
        elsif postgresql?
          @default_db_url = '"postgres://user:password@localhost:5432/app_#{environment}"'
          @db_gem = "pg"
        else
          @default_db_url = '"sqlite://db/#{environment}.db"'
          @db_gem = "sqlite3"
        end
      end
      # rubocop:enable Lint/InterpolationCheck

      def project_name=(val)
        if !(val =~ VALID_PROJECT_NAME_REGEX)
          raise InvalidValue, "Project name must start with a letter and contains only letters, numbers and _"
        end

        @project_name = val
      end

      def rspec?
        tests == rspec_id
      end

      def minitest?
        tests == minitest_id
      end

      # rubocop:disable Lint/InterpolationCheck
      def foo_bar_example
        return 'view("bar")' if fullstack?

        '{ foo: "bar" }'
      end

      def root_example
        return 'view("index")' if fullstack?

        '{ message: "#{t.hello.message}" }'
      end
      # rubocop:enable Lint/InterpolationCheck

      def fullstack?
        base == fullstack_id
      end

      def api?
        base == api_id
      end

      def minimal?
        base == minimal_id
      end

      def rodauth?
        rodauth == true
      end

      def database?
        database == true
      end

      def mysql?
        return false unless database?

        database_type == mysql_id
      end

      def postgresql?
        return false unless database?

        database_type == postgresql_id
      end

      def sqlite?
        return false unless database?

        database_type == sqlite_id
      end

      def const_project_name
        @const_project_name ||= project_name.split("_").map(&:capitalize).join
      end
    end
  end
end
