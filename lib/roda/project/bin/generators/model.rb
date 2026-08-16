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

            puts "* creating model"
            create_model
            create_model_test
            Migration.new(args: [migration_name].concat(field_args)).call
          end

          def create_model_test
            ensure_and_get_path("spec/app/models", model_relative_path)
            filename = File.join("spec/app/models", *name_segments[0..-2], "#{model_file_basename}_spec.rb")
            File.write(filename, spec_code)

            action_success_message(filename)
          end

          def create_model
            ensure_and_get_path("app/models", model_relative_path)
            filename = File.join("app/models", *name_segments[0..-2], "#{model_file_basename}.rb")
            File.write(filename, code)

            action_success_message(filename)
          end

          def spec_code
            depth = 2 + name_segments.length - 1
            relative_prefix = "../" * depth
            <<~RUBY
              require_relative "#{relative_prefix}spec_helper"

              describe #{qualified_class_name} do
              end
            RUBY
          end

          def code
            if name_segments.length == 1
              <<~RUBY
                class #{qualified_class_name}
                end
              RUBY
            else
              depth = name_segments.length - 1
              class_indent = "  " * depth
              lines = [
                "#{class_indent}class #{camelize(name_segments.last)} < Sequel::Model(:#{table_name})",
                "#{class_indent}end"
              ]

              name_segments[0..-2].map { |s| camelize(s) }.reverse.each_with_index do |mod, idx|
                mod_indent = "  " * (depth - 1 - idx)
                lines = ["#{mod_indent}class #{mod}"] + lines + ["#{mod_indent}end"]
              end

              lines.join("\n") + "\n"
            end
          end

          def migration_name
            segs = name_segments.map { |s| camelize(s) }
            segs[-1] = pluralize(segs[-1])
            "Create" + segs.join("_")
          end

          def name_segments
            @name_segments ||= @args[0].to_s.split("/")
          end

          def qualified_class_name
            @qualified_class_name ||= name_segments.map { |s| camelize(s) }.join("::")
          end

          def flat_class_name
            @flat_class_name ||= name_segments.map { |s| camelize(s) }.join
          end

          def table_name
            @table_name ||= begin
              segs = name_segments.map { |s| underscore(camelize(s)) }
              segs[-1] = pluralize(segs[-1])
              segs.join("_")
            end
          end

          def model_relative_path
            @model_relative_path ||= if name_segments.length > 1
              File.join(*name_segments[0..-2], model_file_basename)
            else
              model_file_basename
            end
          end

          def model_file_basename
            @model_file_basename ||= underscore(name_segments.last)
          end

          def model_name
            @model_name ||= @args[0].nil? ? nil : qualified_class_name
          end

          def field_args
            @field_args ||= @args[1..] || []
          end
        end
      end
    end
  end
end
