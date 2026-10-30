# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators
        class Routes
          class Route
            VALID_METHODS = %w[get post delete put patch].freeze

            attr_reader :method, :name

            def self.parse(route_str)
              method, name = route_str.split(":", 2)

              if name && VALID_METHODS.include?(method)
                new(method, name)
              elsif name.nil? && VALID_METHODS.include?(route_str)
                new(route_str, nil)
              else
                new("get", route_str)
              end
            end

            def initialize(method, name)
              @method = method
              @name = name
            end

            def get?
              method == "get"
            end
          end
        end
      end
    end
  end
end
