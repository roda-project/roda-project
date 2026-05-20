module Roda
  module Project
    module Helpers
      module Input
        def read_line(prompt, default)
          val = reader.read_line(prompt).chomp
          return default if val == ""
          return false if val == "n"
          return true if val == "Y" # Add this line

          val
        end

        def reader
          @reader ||= TTY::Reader.new
        end
      end
    end
  end
end
