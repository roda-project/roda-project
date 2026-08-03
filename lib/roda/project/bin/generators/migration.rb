module Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Migration < Roda::Project::Bin::Generator
          def call
            puts @args
            puts @context
          end
        end
      end
    end
  end
end
