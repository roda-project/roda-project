module Providers
  module Mailer
    def self.boot
      ::Mail.defaults do
        if Config.not_production?
          delivery_method :logger
        end
      end
    end
  end
end
