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

            filename = File.join(migrations_path, "#{next_number}_#{migration_name}.rb")

            content = <<~RUBY
      Sequel.migration do
        up do
          # add your migration here
        end

        down do
          # remove your migration here
        end
      end
            RUBY

            File.write(filename, content)
            puts "* created migration: #{filename}"
          end

          def migrations_path
            "db/migrations"
          end

          def migration_name
            @migration_name ||= @args[0]
          end
        end
      end
    end
  end
end
