class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Service < Roda::Project::Bin::Generator
          include Roda::Project::Helpers::Inflections

          def call
            unless valid_args?
              puts "Usage: bin/roda g service <module|class> <name>"
              exit 1
            end

            puts "* creating service"
            create_service
            create_service_spec
          end

          def create_service
            ensure_and_get_path("app/services", service_relative_path)
            filename = File.join("app/services", *name_segments[0..-2], "#{service_file_basename}.rb")
            File.write(filename, code)

            action_success_message(filename)
          end

          def create_service_spec
            ensure_and_get_path("spec/app/services", service_relative_path)
            filename = File.join("spec/app/services", *name_segments[0..-2], "#{service_file_basename}_spec.rb")
            File.write(filename, spec_code)

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
            leaf_keyword = service_type
            if name_segments.length == 1
              <<~RUBY
                #{leaf_keyword} #{camelize(name_segments.last)}
                end
              RUBY
            else
              depth = name_segments.length - 1
              leaf_indent = "  " * depth
              lines = [
                "#{leaf_indent}#{leaf_keyword} #{camelize(name_segments.last)}",
                "#{leaf_indent}end"
              ]

              name_segments[0..-2].map { |s| camelize(s) }.reverse.each_with_index do |mod, idx|
                mod_indent = "  " * (depth - 1 - idx)
                lines = ["#{mod_indent}module #{mod}"] + lines + ["#{mod_indent}end"]
              end

              lines.join("\n") + "\n"
            end
          end

          def name_segments
            @name_segments ||= service_name.split("/")
          end

          def qualified_class_name
            @qualified_class_name ||= name_segments.map { |s| camelize(s) }.join("::")
          end

          def service_relative_path
            @service_relative_path ||= if name_segments.length > 1
              File.join(*name_segments[0..-2], service_file_basename)
            else
              service_file_basename
            end
          end

          def service_file_basename
            @service_file_basename ||= underscore(name_segments.last)
          end

          def service_type
            @service_type ||= @args[0].to_s.downcase
          end

          def service_name
            @service_name ||= @args[1].to_s
          end

          def valid_args?
            return false unless %w[module class].include?(service_type)
            return false if service_name.empty?
            return false if service_name.include?(" ")
            return false if service_name.match?(/\A\d/)

            true
          end
        end
      end
    end
  end
end
