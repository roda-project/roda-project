module Roda
  module Project
    module Helpers
      module Template
        def erb_cp_dir(type, path)
          TTY::File.copy_directory(
            File.expand_path("#{templates_root}/#{type}/#{path}", __dir__),
            "#{@dir}#{@context.project_name}/#{path}",
            context: @context
          )
        end

        def erb_cp_file(type, path)
          TTY::File.copy_file(
            File.expand_path("#{templates_root}/#{type}/#{path}", __dir__),
            "#{@dir}#{@context.project_name}/#{path}",
            context: @context
          )
        end

        # For copy without parse ERB files
        def cp_dir(type, path)
          FileUtils.cp_r(
            File.expand_path("#{templates_root}/#{type}/#{path}", __dir__),
            "#{@dir}#{@context.project_name}/#{path}"
          )
        end

        # For copy without parse ERB files
        def cp_file(type, path)
          File.write(
            "#{@dir}#{@context.project_name}/#{path}",
            File.read(File.expand_path("#{templates_root}/#{type}/#{path}", __dir__))
          )
        end

        def templates_root
          @templates_root ||= "../templates"
        end
      end
    end
  end
end
