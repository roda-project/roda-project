module Providers
  module Logger
    def self.boot
      @logger = ::Logger.new(STDOUT)
    end

    def self.get = @logger
  end
end
