module Discord
  class Guilds
    def initialize(request)
      @request = request
    end

    def call
      user_guilds
    end

    private

    attr_reader :request

    def user_guilds
      HTTParty.get(ENV['DISCORD_GUILDS_URL'], headers: { 'Authorization': "Bearer #{token}" })
    end

    def token
      request.env['omniauth.auth'].credentials.token
    end
  end
end
