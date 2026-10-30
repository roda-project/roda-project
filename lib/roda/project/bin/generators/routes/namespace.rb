# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators
        class Routes
          module Namespace
            module_function

            def for_path(sub_path)
              sub_path.include?("/") ? ":\"#{sub_path}\"" : ":#{sub_path}"
            end

            def hash_branches_line(sub_path)
              "r.hash_branches(#{for_path(sub_path)})"
            end
          end
        end
      end
    end
  end
end
