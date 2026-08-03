require_relative "../../project"

class Roda
  module Project
    module Bin
      class Generators < ::Thor
        desc "migration", "Create a database migration"
        def migration(*args)
          Migration.new(context:, args:).call
        end

        desc "routes", "Create routes inside hash_branches, views and tests"
        def routes(*args)
          Routes.new(context:, args:).call
        end

        private

        def context
          return @context if @context

          @context = Roda::Project::MainContext.new
          @context.project_name = options[:main_context][:project_name]
          @context.base = options[:main_context][:base]
          @context.database = options[:main_context][:database]
          @context.database_type = options[:main_context][:database_type]
          @context.rodauth = options[:main_context][:rodauth]
          @context.tests = options[:main_context][:test]

          @context
        end
      end
    end
  end
end
