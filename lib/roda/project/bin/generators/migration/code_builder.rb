# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators
        class Migration
          class CodeBuilder
            attr_reader :detection, :fields

            def initialize(detection:, fields:)
              @detection = detection || {}
              @fields = fields || []
            end

            def build
              action = detection[:action]

              case action
              when :create_table
                build_create_table
              when :add_columns
                build_add_columns
              when :drop_columns
                build_drop_columns
              when :create_join_table
                build_create_join_table
              else
                build_generic
              end
            end

            private

            def build_create_table
              table = detection[:table_name]
              lines = []
              lines << "Sequel.migration do"
              lines << "  change do"
              lines << "    create_table(:#{table}) do"
              lines << "      primary_key :id"

              indexes = []

              fields.each do |field|
                if field[:is_reference]
                  ref_line = "      foreign_key :#{field[:name]}, :#{field[:target_table]}"
                  ref_line += format_options(field[:options]) unless field[:options].empty?
                  lines << ref_line
                  indexes << "      index :#{field[:name]}" if field[:index]
                else
                  col_line = "      #{field[:type]} :#{field[:name]}"
                  col_line += format_options(field[:options]) unless field[:options].empty?
                  lines << col_line

                  if field[:index] == :unique
                    indexes << "      index :#{field[:name]}, unique: true"
                  elsif field[:index]
                    indexes << "      index :#{field[:name]}"
                  end

                  if field[:composite_index]
                    cols_str = field[:composite_index].map { |c| ":#{c}" }.join(", ")
                    indexes << "      index [#{cols_str}]"
                  end
                end
              end

              lines << "      DateTime :created_at"
              lines << "      DateTime :updated_at"

              unless indexes.empty?
                lines << ""
                lines.concat(indexes)
              end

              lines << "    end"
              lines << "  end"
              lines << "end"
              lines.join("\n") + "\n"
            end

            def build_add_columns
              table = detection[:table_name]
              lines = []
              lines << "Sequel.migration do"
              lines << "  change do"
              lines << "    alter_table(:#{table}) do"

              fields.each do |field|
                if field[:is_reference]
                  ref_line = "      add_foreign_key :#{field[:name]}, :#{field[:target_table]}"
                  ref_line += format_options(field[:options]) unless field[:options].empty?
                  lines << ref_line
                  lines << "      add_index :#{field[:name]}" if field[:index]
                else
                  col_line = "      add_column :#{field[:name]}, #{field[:type]}"
                  col_line += format_options(field[:options]) unless field[:options].empty?
                  lines << col_line

                  if field[:index] == :unique
                    lines << "      add_index :#{field[:name]}, unique: true"
                  elsif field[:index]
                    lines << "      add_index :#{field[:name]}"
                  end

                  if field[:composite_index]
                    cols_str = field[:composite_index].map { |c| ":#{c}" }.join(", ")
                    lines << "      add_index [#{cols_str}]"
                  end
                end
              end

              lines << "    end"
              lines << "  end"
              lines << "end"
              lines.join("\n") + "\n"
            end

            def build_drop_columns
              table = detection[:table_name]
              lines = []
              lines << "Sequel.migration do"
              lines << "  change do"
              lines << "    alter_table(:#{table}) do"

              fields.each do |field|
                lines << "      drop_column :#{field[:name]}"
              end

              lines << "    end"
              lines << "  end"
              lines << "end"
              lines.join("\n") + "\n"
            end

            def build_create_join_table
              tables = detection[:tables] || []
              args_str = tables.map { |fk, tbl| "#{fk}: :#{tbl}" }.join(", ")

              lines = []
              lines << "Sequel.migration do"
              lines << "  change do"
              lines << "    create_join_table(#{args_str})"
              lines << "  end"
              lines << "end"
              lines.join("\n") + "\n"
            end

            def build_generic
              <<~RUBY
                Sequel.migration do
                  up do
                    # add your migration here
                  end

                  down do
                    # remove your migration here
                  end
                end
              RUBY
            end

            def format_options(opts)
              return "" if opts.empty?

              formatted = opts.map do |k, v|
                val_str = case v
                          when Array
                            "[#{v.join(', ')}]"
                          when Symbol
                            ":#{v}"
                          else
                            v.inspect
                          end
                "#{k}: #{val_str}"
              end.join(", ")

              ", #{formatted}"
            end
          end
        end
      end
    end
  end
end
