# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Migration
          class ActionDetector
            attr_reader :name, :args

            def initialize(name, args: [])
              @name = name.to_s
              @args = args || []
            end

            def detect
              camel_name = camelize(name)

              if (m = camel_name.match(/^CreateJoinTable(?<t1>[A-Z][a-zA-Z0-9]*?)(?<t2>[A-Z][a-zA-Z0-9]*)$/)) ||
                 (m = camel_name.match(/JoinTable(?<t1>[A-Z][a-zA-Z0-9]*?)(?<t2>[A-Z][a-zA-Z0-9]*)$/)) ||
                 camel_name.start_with?("CreateJoinTable") || camel_name.include?("JoinTable")
                tables = parse_join_tables(m)
                { action: :create_join_table, tables: tables }
              elsif (m = camel_name.match(/^Create(?<table_name>[A-Z0-9].*)$/))
                { action: :create_table, table_name: pluralize(underscore(m[:table_name])) }
              elsif (m = camel_name.match(/^Add.+To(?<table_name>[A-Z0-9].*)$/))
                { action: :add_columns, table_name: pluralize(underscore(m[:table_name])) }
              elsif (m = camel_name.match(/^Remove.+From(?<table_name>[A-Z0-9].*)$/))
                { action: :drop_columns, table_name: pluralize(underscore(m[:table_name])) }
              else
                { action: :generic, table_name: nil }
              end
            end

            private

            def camelize(str)
              return str if str =~ /[A-Z]/

              str.split("_").map(&:capitalize).join
            end

            def underscore(str)
              str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                 .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                 .tr("-", "_")
                 .downcase
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

            def parse_join_tables(match)
              if args.size >= 2
                args[0..1].map do |arg|
                  clean = underscore(arg.to_s.gsub(/:.*$/, ""))
                  s_clean = singularize(clean)
                  p_clean = pluralize(s_clean)
                  ["#{s_clean}_id", p_clean]
                end
              elsif match
                raw1 = underscore(match[:t1])
                raw2 = underscore(match[:t2])
                s1 = singularize(raw1)
                s2 = singularize(raw2)
                t1 = pluralize(s1)
                t2 = pluralize(s2)
                [["#{s1}_id", t1], ["#{s2}_id", t2]]
              else
                []
              end
            end
          end
        end
      end
    end
  end
end
