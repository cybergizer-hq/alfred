module OmniauthMacros
  def yandex_hash
    OmniAuth.config.mock_auth[:yandex] =
      OmniAuth::AuthHash.new({
                               "provider": 'yandex',
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
