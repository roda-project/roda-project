class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Service < Roda::Project::Bin::Generator
          include Roda::Project::Helpers::Inflections

          def call
          end
        end
      end
    end
  end
end
