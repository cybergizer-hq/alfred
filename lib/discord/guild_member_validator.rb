module Discord
  class GuildMemberValidator
    def initialize(guilds, server_id)
      @guilds = guilds
      @server_id = server_id
    end

    def call
      guild_member?
    end

    private

    attr_reader :guilds, :server_id

    def guild_member?
      guilds.any? { |guild| guild['id'].eql?(server_id) }
    end
  end
end
