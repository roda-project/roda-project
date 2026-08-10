# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Model < Roda::Project::Bin::Generator
          include Roda::Project::Helpers::Inflections

          def call
            filename = File.join(ensure_and_get_path("app/models"), "#{underscore(model_name)}.rb")
            File.write(filename, content)
            puts "* created model file: #{filename}"
            Migration.new(args: ([migration_name] << field_args))
          end

          def code
            <<~RUBY
                class #{model_name}
                end
            RUBY
          end

          def migration_name
            "Create" << pluralize(model_name)
          end

          def model_name
            @model_name ||= camelize(@args[0])
          end

          def field_args
            @field_args ||= (@args[1..] || [])
          end
        end
      end
    end
  end
end
