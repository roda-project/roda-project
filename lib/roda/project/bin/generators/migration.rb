module Roda
  module Project
    module Bin
      module Generators
        class Migration < Roda::Project::Bin::Generator
          class Context
          end

          def call
            retry_on_error { @context = read_input('Enter the migration name') }
          end
        end
      end
    end
  end
end
