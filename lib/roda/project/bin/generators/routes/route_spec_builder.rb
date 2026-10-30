# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators
        class Routes
          class RouteSpecBuilder
            def initialize(branch_name:, routes:)
              @branch_name = branch_name
              @routes = routes
            end

            def content
              [
                "require_relative \"#{relative_spec_helper_path}\"",
                "",
                "describe \"Routes for #{@branch_name}\" do",
                test_definitions,
                "end",
                ""
              ].join("\n")
            end

            private

            def test_definitions
              @routes.map { |route| build_test_definition(route) }.join("\n")
            end

            def build_test_definition(route)
              test_name = route.name ? " /#{@branch_name}/#{route.name}" : " /#{@branch_name}"
              test_path = route.name ? " \"/#{@branch_name}/#{route.name}\"" : " \"/#{@branch_name}\""

              "  it \"responds to #{route.method.upcase}#{test_name}\" do\n" \
                "    #{route.method}#{test_path}\n" \
                "    expect(last_response.status).to eq(200)\n" \
                "  end"
            end

            def relative_spec_helper_path
              prefix = "../" * (2 + @branch_name.count("/"))
              "#{prefix}spec_helper"
            end
          end
        end
      end
    end
  end
end
