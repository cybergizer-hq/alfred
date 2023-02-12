Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord, '1072876631200378971', '8df26ae30fb61b1c9ab2d95f38b1a79c92505b6bf84bcb771e401c3042a43400', scope: 'email identify guilds', callback_url: 'http://localhost:3000/users/auth/discord'
end