module Config
  class << self
    def get
      @config ||= {
        secret: ENV["SESSION_SECRET"] || 'UAe&&3q8<FQF8HiF)>l0hbPk£vBQ#IrYsoO}14k\l+-/gIU[j}l0hbPk£vBQ#IrY',
        environment:,
        i18n: {
          translations: ["app/config/locales", "app/config/locales/foo"],
          locale: ["pt-br", "en"]
        },
        db: {
          url: not_production? ? "postgres://dev:dev@localhost:5432/app_#{environment}" : ENV["DATABASE_URL"]
        }
      }
    end

    def not_production? = environment != "production"

    def environment
      ENV["RACK_ENV"] || "development"
    end
  end
end
