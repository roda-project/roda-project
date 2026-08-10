# frozen_string_literal: true

class Roda
  module Project
    module Helpers
      module Inflections
        module_function

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
      end
    end
  end
end
