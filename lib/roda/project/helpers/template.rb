module Roda
  module Project
    module Helpers
      module Template
        def tty_cp_r(type, path)
          TTY::File.copy_directory(
            File.expand_path("../../templates/#{type}/#{path}", __dir__),
            "#{@dir}#{@context.project_name}/#{path}",
            context: @context
          )
        end

        def tty_cp(type, path)
          TTY::File.copy_file(
            File.expand_path("../../templates/#{type}/#{path}", __dir__),
            "#{@dir}#{@context.project_name}/#{path}",
            context: @context
          )
        end

        def cp_r(type, path)
          FileUtils.cp_r(
            File.expand_path("../../templates/#{type}/#{path}", __dir__),
            "#{@dir}#{@context.project_name}/#{path}"
          )
        end

        def cp(type, path)
          File.write(
            "#{@dir}#{@context.project_name}/#{path}",
            File.read(File.expand_path("../../templates/#{type}/#{path}", __dir__))
          )
        end
      end
    end
  end
end
