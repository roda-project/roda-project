# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators
        class Migration
          class FieldParser
            TYPE_MAP = {
              "string" => "String",
              "text" => "String",
              "integer" => "Integer",
              "bigint" => "Bignum",
              "float" => "Float",
              "decimal" => "BigDecimal",
              "datetime" => "DateTime",
              "timestamp" => "DateTime",
              "time" => "Time",
              "date" => "Date",
              "boolean" => "TrueClass",
              "binary" => "File",
              "json" => ":json",
              "jsonb" => ":jsonb",
              "uuid" => ":uuid"
            }.freeze

            attr_reader :raw_fields

            def initialize(raw_fields)
              @raw_fields = raw_fields || []
            end

            def parse
              fields = []

              raw_fields.each do |raw_field|
                parts = raw_field.to_s.split(":")
                next if parts.empty?

                name = parts[0]
                type_part = parts[1] || "string"
                index_part = parts[2]

                # Extract modifier e.g. string{50}, decimal{10.2}, references{polymorphic}
                type, modifier = extract_type_and_modifier(type_part)

                if type == "references" || type == "belongs_to"
                  if modifier == "polymorphic"
                    fields << {
                      name: "#{name}_id",
                      type: "Bignum",
                      options: {},
                      index: false,
                      composite_index: ["#{name}_type", "#{name}_id"]
                    }
                    fields << {
                      name: "#{name}_type",
                      type: "String",
                      options: {},
                      index: false
                    }
                  else
                    singular_name = singularize(name)
                    plural_table = pluralize(singular_name)
                    fields << {
                      name: "#{name}_id",
                      is_reference: true,
                      target_table: plural_table,
                      index: true,
                      options: {}
                    }
                  end
                else
                  sequel_type = TYPE_MAP[type] || "String"
                  options = {}

                  options[:text] = true if type == "text"

                  if modifier
                    if modifier.include?(".")
                      prec, scale = modifier.split(".").map(&:to_i)
                      options[:size] = [prec, scale]
                    elsif modifier =~ /^\d+$/
                      options[:size] = modifier.to_i
                    end
                  end

                  index_val = parse_index_spec(index_part)

                  fields << {
                    name: name,
                    type: sequel_type,
                    options: options,
                    index: index_val
                  }
                end
              end

              fields
            end

            private

            def extract_type_and_modifier(type_part)
              if type_part =~ /^(.*?)\{(.*?)\}$/
                [Regexp.last_match(1), Regexp.last_match(2)]
              else
                [type_part, nil]
              end
            end

            def parse_index_spec(index_part)
              case index_part
              when "uniq", "unique"
                :unique
              when "index"
                true
              else
                false
              end
            end

            def singularize(str)
              if str.end_with?("ies")
                "#{str[0..-4]}y"
              elsif str.end_with?("es") && !str.end_with?("ques")
                str[0..-3]
              elsif str.end_with?("s") && !str.end_with?("ss")
                str[0..-2]
              else
                str
              end
            end

            def pluralize(str)
              return str if str.end_with?("s")

              if str.end_with?("y") && !str.end_with?("ay", "ey", "oy", "uy")
                "#{str[0..-2]}ies"
              elsif str.end_with?("s", "x", "z", "ch", "sh")
                "#{str}es"
              else
                "#{str}s"
              end
            end
          end
        end
      end
    end
  end
end
