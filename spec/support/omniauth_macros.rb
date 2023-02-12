module OmniauthMacros
  def discord_hash
    OmniAuth.config.mock_auth[:discord] =
      OmniAuth::AuthHash.new({
                               "provider": 'discord',
                               "uid": '123545',
                               "info": {
                                 "email": 'test@cybergizer.com'
                               },
                               "extra": {
                                 "raw_info": {
                                   'first_name': 'John',
                                   'last_name': 'Doe'
                                 }
                               }
                             })
  end
end
