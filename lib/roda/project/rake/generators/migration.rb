module Roda
  module Project
    module Rake
      module Generators
        class Migration < Roda::Project::Generator
          class Context
          end

          def call
          end

          def templates_root
            @templates_root ||= "../rake/generators/templates"
          end
        end
      end
    end
  end
end
