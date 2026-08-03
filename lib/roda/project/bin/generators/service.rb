# rubocop:disable Layout/HeredocIndentation
class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Migration < Roda::Project::Bin::Generator
          def call
          end

          def migrations_path
            "db/migrations"
          end

          def service_name
            @migration_name ||= @args[0]
          end
        end
      end
    end
  end
end
# rubocop:enable Layout/HeredocIndentation
