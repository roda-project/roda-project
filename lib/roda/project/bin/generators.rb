module Roda
  module Project
    module Bin
      module Generators < Thor
        # Roda::Project::Bin::Generators.call(context, ARGV)
        def call(context, argv)
          puts context
          puts argv
          #send(generator_name, context)
        end

        #def migration(context) = Migration.new(context:)
      end
    end
  end
end
