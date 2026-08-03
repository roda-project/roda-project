module Providers
  module Logger
    def self.boot
      @logger = ::Logger.new($stdout)
    end

    def self.get = @logger
  end
end
