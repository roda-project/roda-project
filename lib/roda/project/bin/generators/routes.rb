# rubocop:disable Layout/HeredocIndentation
class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Routes < Roda::Project::Bin::Generator
          def call
            if branch_name.nil? || branch_name.empty? || routes_list.nil? || routes_list.empty?
              puts "Usage: bin/roda g routes branch_name route1 route2:method"
              exit 1
            end

            puts "* creating routes"
            generate_routes
            generate_views
            generate_tests
            print_nested_branch_reminder
          end

          private

          def generate_routes
            filename = File.join(ensure_and_get_path("app/routes", branch_name), "#{branch_name}.rb")
            route_definitions = routes_list.map do |route_str|
              method, name = parse_route_string(route_str)
              view_name = name
              view_name = "index" if view_name == ""
              view_line = (method == "get" && must_generate_views?) ? "\n      view('#{view_name}')" : ""

              if name != ""
                "    r.#{method} \"#{name}\" do#{view_line}\n    end"
              else
                "    r.#{method} do#{view_line}\n    end"
              end
            end.join("\n\n")

            hash_branch_header = if branch_name.include?("/")
              parts = branch_name.split("/")
              sub_path = parts[0..-2].join("/")
              namespace = sub_path.include?("/") ? ":\"#{sub_path}\"" : ":#{sub_path}"
              branch_segment = parts.last
              "hash_branch #{namespace}, \"#{branch_segment}\" do |r|"
            else
              "hash_branch \"#{branch_name}\" do |r|"
            end

            content = <<~RUBY
      class #{@context.const_project_name}
        #{hash_branch_header}
      #{route_definitions}
        end
      end
            RUBY
            File.write(filename, content)
            puts_create_message(filename)
          end

          def generate_views
            if must_generate_views?
              branch_views_dir = File.join("app/views", branch_name)
              FileUtils.mkdir_p(branch_views_dir)
              routes_list.each do |route_str|
                method, name = parse_route_string(route_str)
                if method == "get"
                  name = "index" if name == ""
                  view_filename = File.join(branch_views_dir, "#{name}.erb")
                  File.write(view_filename, "")
                  puts_create_message(view_filename)
                end
              end
            end
          end

          def generate_tests
            test_filename = File.join(ensure_and_get_path("spec/app/routes", branch_name), "#{branch_name}_spec.rb")
            nesting_level = branch_name.count("/")
            relative_spec_helper_path = "../" * (2 + nesting_level) + "spec_helper"

            test_route_definitions = routes_list.map do |route_str|
              method, name = parse_route_string(route_str)

              if name != ""
                "  it \"responds to #{method.upcase} /#{branch_name}/#{name}\" do\n" \
                  "    #{method} \"/#{branch_name}/#{name}\"\n" \
                  "    expect(last_response.status).to eq(200)\n" \
                  "  end"
              else
                "  it \"responds to #{method.upcase} /#{branch_name} do\n" \
                  "    #{method} \"/#{branch_name}\n" \
                  "    expect(last_response.status).to eq(200)\n" \
                  "  end"
              end
            end.join("\n")

            test_content = <<~RUBY
      require_relative "#{relative_spec_helper_path}"

      describe "Routes for #{branch_name}" do
      #{test_route_definitions}
      end
            RUBY
            File.write(test_filename, test_content)
            puts_create_message(test_filename)
          end

          def must_generate_views?
            @options[:views] && Dir.exist?("app/views")
          end

          def parse_route_string(route_str)
            name, method = route_str.split(":", 2)
            method ||= "get"
            [method, name]
          end

          def routes_list
            @routes_list ||= @args[1..]
          end

          def branch_name
            @branch_name ||= @args[0]
          end

          def print_nested_branch_reminder
            return unless branch_name.include?("/")

            parts = branch_name.split("/")
            sub_path = parts[0..-2].join("/")
            namespace = sub_path.include?("/") ? ":\"#{sub_path}\"" : ":#{sub_path}"

            puts "\ndont forget to add:\n\n" \
                 "autoload_hash_branch_dir(#{namespace}, \"./app/routes/#{sub_path}\")\n\n" \
                 "route do |r|\n" \
                 " r.on(\"#{sub_path}\") { r.hash_branches(#{namespace}) }\n" \
                 "end\n"
          end
        end
      end
    end
  end
end
# rubocop:enable Layout/HeredocIndentation
