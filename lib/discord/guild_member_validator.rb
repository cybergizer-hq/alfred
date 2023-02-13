module Discord
  class GuildMemberValidator
    def initialize(request)
      @request = request
    end

    def self.call(*args)
      new(*args).guild_member?
    end

    def guild_member?
      guilds.any? { |guild| guild['id'].eql?(ENV['DISCORD_GUILD_ID']) } if valid_guilds?
    end

    private

    attr_reader :request

    def guilds
      @guilds ||= HTTParty.get(ENV['DISCORD_GUILDS_URL'], headers: { 'Authorization': "Bearer #{token}" })
    end

    def token
      request.env['omniauth.auth']&.credentials&.token
    end

    def valid_guilds?
      guilds.message.eql?('OK')
    end
  end
end
