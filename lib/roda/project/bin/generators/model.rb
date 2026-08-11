class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Model < Roda::Project::Bin::Generator
          include Roda::Project::Helpers::Inflections

          def call
            if model_name.nil? || field_args == []
              puts "Usage: bin/roda g model name field1 field2"
              exit 1
            end

            if model_name.include?("/")
              puts "'/' nested models not supported"
              exit 1
            end

            filename = File.join(ensure_and_get_path("app/models", underscore(model_name)), "#{underscore(model_name)}.rb")
            File.write(filename, code)
            puts "* created model file: #{filename}"
            Migration.new(args: ([migration_name].concat(field_args))).call
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
