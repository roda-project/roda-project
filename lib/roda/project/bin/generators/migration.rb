# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Migration < Roda::Project::Bin::Generator
          def call
            if migration_name.nil? || migration_name.empty?
              puts "Usage: bin/roda g migration your_migration_name"
              exit 1
            end

            FileUtils.mkdir_p(migrations_path) unless File.directory?(migrations_path)

            existing_migrations = Dir.glob(File.join(migrations_path, "*.rb"))
            max_number = existing_migrations.map do |file|
              File.basename(file).match(/^(\d+)/)&.captures&.first.to_i
            end.max || 0
            next_number = (max_number + 1).to_s.rjust(3, "0")

            formatted_name = underscore(migration_name)
            filename = File.join(migrations_path, "#{next_number}_#{formatted_name}.rb")

            detection = ActionDetector.new(migration_name, args: field_args).detect
            fields = FieldParser.new(field_args).parse
            content = CodeBuilder.new(detection: detection, fields: fields).build

            File.write(filename, content)
            puts "* created migration: #{filename}"
          end

          def migrations_path
            "db/migrations"
          end

          def migration_name
            @migration_name ||= @args[0]
          end

          def field_args
            @field_args ||= (@args[1..] || [])
          end

          private

          def underscore(str)
            str.to_s.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
               .gsub(/([a-z\d])([A-Z])/, '\1_\2')
               .tr("-", "_")
               .downcase
          end
        end
      end
    end
  end
end
