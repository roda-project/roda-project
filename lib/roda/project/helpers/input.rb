module Roda
  module Project
    module Helpers
      module Input
        def read_line(prompt, default)
          val = reader.read_line(prompt).chomp
          return default if val == ""
          return false if val == "n"
          return true if val == "Y" || val == "y"

          val
        end

        def reader
          @reader ||= TTY::Reader.new
        end

        def retry_on_error
          yield
        rescue Roda::Project::Error => e
          puts "\n #{pastel.red(e.message)} \n\n"

          yield
        end

        def pastel
          @pastel ||= Pastel.new
        end
      end
    end
  end
end
