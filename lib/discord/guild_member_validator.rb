module Discord
  class GuildMemberValidator
    def initialize(request)
      @request = request
    end

    def self.call(*args)
      new(*args).guild_member?
    end

    def guild_member?
      guilds.any? { |guild| guild['id'].eql?(ENV['CYBERGIZER_GUILD_ID']) }
    end

    private

    attr_reader :request

    def guilds
      HTTParty.get(ENV['DISCORD_GUILDS_URL'], headers: { 'Authorization': "Bearer #{token}" })
    end

    def token
      request.env['omniauth.auth'].credentials.token
    end
  end
end
