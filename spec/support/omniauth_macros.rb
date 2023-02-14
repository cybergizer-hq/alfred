module OmniauthMacros
  def discord_hash
    OmniAuth.config.mock_auth[:discord] =
      OmniAuth::AuthHash.new({
                               "uid": Faker::Number.number(digits: 6),
                               "info": {
                                 "email": Faker::Internet.email,
                                 "name": Faker::Name.name
                               }
                             })
  end
end
