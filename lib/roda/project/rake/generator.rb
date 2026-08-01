module Roda
  module Project
    module Rake
      class Generator < Roda::Project::Generator
        def templates_root
          @templates_root ||= "../rake/generators/templates"
        end
      end
    end
  end
end
