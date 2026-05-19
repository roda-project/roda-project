module Config
  class << self
    def get
      @config ||= {
        secret: ENV["SESSION_SECRET"] || 'REPLACE-----8HiF)>l0hbPk£vBQ#IrYsoO}14k\l+-/gIU[j}l0hbPk£vBQ#IrY',
        environment:,
        hmac_secret: ENV["RODAUTH_HMAC_SECRET"] || 'REPLACE',
        jwt_secret: ENV["JWT_SECRET"] || 'REPLACE',
        i18n: {
          translations: ["app/config/locales", "app/config/locales/foo"],
          locale: ["pt-br", "en"]
        },
        db: {
          url: not_production? ? "sqlite://db/#{environment}.db" : ENV["DATABASE_URL"]
        }
      }
    end

    def not_production? = environment != "production"

    def environment
      ENV["RACK_ENV"] || "development"
    end
  end
end
