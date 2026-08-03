module Roda
  module Project
    module Bin
      class Generator < Roda::Project::Generator
        def templates_root
          @templates_root ||= "../bin/generators/templates"
        end
      end
    end
  end
end
