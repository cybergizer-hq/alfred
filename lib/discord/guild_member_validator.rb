module Discord
  class GuildMemberValidator
    def initialize(request, server_id)
      @request = request
      @server_id = server_id
    end

    def call
      guild_member?
    end

    private

    attr_reader :request, :server_id

    def guild_member?
      guilds.any? { |guild| guild['id'].eql?(server_id) }
    end

    def guilds
      HTTParty.get(ENV['DISCORD_GUILDS_URL'], headers: { 'Authorization': "Bearer #{token}" })
    end

    def token
      request.env['omniauth.auth'].credentials.token
    end
  end
end
