module Providers
  module DB
    class Conn
      def self.boot
        # @conn = Sequel.connect("jdbc:sqlite:db/#{Config.get[:environment]}.db")
        # @conn = Sequel.connect("sqlite://db/#{Config.get[:environment]}.db")
        @conn = Sequel.connect(Config.get[:db][:url])

        Sequel::Model.plugin :timestamps, update_on_create: true
      end

      def self.get = @conn
    end
  end
end
