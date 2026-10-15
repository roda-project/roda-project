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
            generate_nested_branch_files
            generate_views
            generate_tests
          end

          private

          def generate_routes
            filename = File.join(ensure_and_get_path("app/routes", branch_name), "#{branch_name}.rb")
            route_definitions = routes_list.map do |route_str|
              method, name = parse_route_string(route_str)
              view_name = name
              view_name = "index" if view_name == nil
              view_line = if method == "get" && must_generate_views?
                if @context.inertia?
                  "\n      inertia('#{inertia_view_path(name)}')"
                else
                  "\n      view('#{view_name}')"
                end
              else
                ""
              end

              if name != nil
                "    r.#{method} \"#{name}\" do#{view_line}\n    end"
              else
                "    r.#{method} do#{view_line}\n    end"
              end
            end.join("\n\n")

            hash_branch_header = if branch_name.include?("/")
              parts = branch_name.split("/")
              sub_path = parts[0..-2].join("/")
              branch_segment = parts.last
              "hash_branch #{namespace_for(sub_path)}, \"#{branch_segment}\" do |r|"
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
            action_success_message(filename)
          end

          def generate_views
            return unless must_generate_views?
            if @context.inertia?
              generate_inertia_views
            else
              generate_erb_views
            end
          end

          def generate_erb_views
            branch_views_dir = File.join("app/views", branch_name)
            FileUtils.mkdir_p(branch_views_dir)
            routes_list.each do |route_str|
              method, name = parse_route_string(route_str)
              if method == "get"
                name = "index" if name == nil
                view_filename = File.join(branch_views_dir, "#{name}.erb")
                File.write(view_filename, "")
                action_success_message(view_filename)
              end
            end
          end

          def generate_inertia_views
            views_dir = "app/assets/js/inertia/views"
            FileUtils.mkdir_p(views_dir)
            routes_list.each do |route_str|
              method, name = parse_route_string(route_str)
              if method == "get"
                component_name = inertia_component_name(name)
                display_path = inertia_display_path(name)
                view_filename = File.join(views_dir, "#{inertia_view_path(name)}.jsx")
                FileUtils.mkdir_p(File.dirname(view_filename))
                File.write(view_filename, inertia_component_content(component_name, display_path))
                action_success_message(view_filename)
              end
            end
          end

          def generate_tests
            test_filename = File.join(ensure_and_get_path("spec/app/routes", branch_name), "#{branch_name}_spec.rb")
            nesting_level = branch_name.count("/")
            relative_spec_helper_path = "../" * (2 + nesting_level) + "spec_helper"

            test_route_definitions = routes_list.map do |route_str|
              method, name = parse_route_string(route_str)

              if name != nil
                "  it \"responds to #{method.upcase} /#{branch_name}/#{name}\" do\n" \
                  "    #{method} \"/#{branch_name}/#{name}\"\n" \
                  "    expect(last_response.status).to eq(200)\n" \
                  "  end"
              else
                "  it \"responds to #{method.upcase} /#{branch_name}\" do\n" \
                  "    #{method} \"/#{branch_name}\"\n" \
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
            action_success_message(test_filename)
          end

          def generate_nested_branch_files
            return unless branch_name.include?("/")

            parts = branch_name.split("/")
            parts[0..-2].each_with_index do |_segment, index|
              prefix = parts[0..index].join("/")
              filename = File.join("app/routes", "#{prefix}.rb")

              if File.exist?(filename)
                ensure_hash_branches_line(filename, namespace_for(prefix))
                next
              end

              dir = File.dirname(filename)
              FileUtils.mkdir_p(dir) unless File.directory?(dir)
              File.write(filename, nested_branch_file_content(prefix, index))
              action_success_message(filename)
            end
          end

          def nested_branch_file_content(prefix, index)
            parts = prefix.split("/")
            segment = parts.last
            header = if index.zero?
              "hash_branch \"#{segment}\" do |r|"
            else
              parent_path = parts[0..-2].join("/")
              "hash_branch #{namespace_for(parent_path)}, \"#{segment}\" do |r|"
            end

            <<~RUBY
              class #{@context.const_project_name}
                #{header} # #{prefix} branch
                  r.hash_branches(#{namespace_for(prefix)}) # #{prefix}/ +1 routes
                end
              end
            RUBY
          end

          def ensure_hash_branches_line(filename, namespace)
            expected_line = "r.hash_branches(#{namespace})"
            return if File.read(filename).include?(expected_line)

            puts "  warning: #{filename} already exists — please add:"
            puts "    #{expected_line}"
          end

          def namespace_for(sub_path)
            sub_path.include?("/") ? ":\"#{sub_path}\"" : ":#{sub_path}"
          end

          def must_generate_views?
            return false unless @options[:views]

            if @context.inertia?
              Dir.exist?("app/assets/js/inertia/views")
            else
              Dir.exist?("app/views")
            end
          end

          def inertia_view_path(name)
            segments = branch_name.split("/")
            segments << (name || "index").capitalize
            segments.join("/")
          end

          def inertia_component_name(name)
            (name || "index").capitalize
          end

          def inertia_display_path(name)
            segments = branch_name.split("/")
            segments << (name || "index")
            segments.join("/")
          end

          def inertia_component_content(component_name, display_path)
            <<~JSX
              import React from 'react'
              import { Link } from '@inertiajs/react'
              import Layout from '../components/Layout'

              const #{component_name} = props => {
                return (<Layout>
                  <div>
                    #{display_path}
                  </div>
                </Layout>)
              }

              export default #{component_name}
            JSX
          end

          def parse_route_string(route_str)
            method, name = route_str.split(":", 2)
            [method, name]
          end

          def routes_list
            @routes_list ||= @args[1..]
          end

          def branch_name
            @branch_name ||= @args[0]
          end
        end
      end
    end
  end
end
# rubocop:enable Layout/HeredocIndentation
