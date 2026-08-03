require_relative "../../project"

module Roda
  module Project
    module Bin
      class Generators < ::Thor
        desc "migration", "create a database migration"
        def migration(*args)
          Migration.new(context:, args:).call
        end

        private

        def context
          return @context if @context

          @context = Roda::Project::MainContext.new
          @context.project_name = "ProjectName"
          @context.base = 1
          @context.database = true
          @context.database_type = 1
          @context.rodauth = 1
          @context.tests = 1
        end
      end
    end
  end
end
