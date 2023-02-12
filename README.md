[![Ruby](https://img.shields.io/badge/Ruby-2.7.1-brightgreen.svg?style=flat)](https://www.ruby-lang.org/en/)
[![Rails](https://img.shields.io/badge/Rails-6.0.2-blue.svg?style=flat)](https://rubyonrails.org/)


# Alfred

Alfred is a proprietary technology for user authentication. This is a standalone application that is used to simplify the authentication process in your client application.

## Features

- Strategy to authenticate with Discord via OAuth2   <img src='https://cdn-icons-png.flaticon.com/512/2111/2111370.png' width='22'>
- Ability to invite users   <img src='https://cdn-icons-png.flaticon.com/512/921/921347.png' width='25'>
- Custom validations for Cybergizer members   <img src='https://cdn-icons-png.flaticon.com/512/508/508250.png' width='25'>
- Token generation   <img src='https://cdn-icons-png.flaticon.com/512/1680/1680173.png' width='25'>

## How to use it?

To authenticate a user through Alfred, follow these steps:

1. Your application must be registered in Alfred.

```bash
ALFRED_HOST = alfred.cybergizer.com
```

## On the frontend

2. You need to redirect user to Alfred (more info [here](https://github.com/cybergizer-hq/alfred/wiki/Authorization-Request)):
    
    ```bash
    'https://{ALFRED_HOST}/oauth/authorize?client_id={UID_OF_YOUR_APPLICATION}&redirect_uri={REDIRECT_URI_OF_YOUR_APPLICATION}&response_type=code&scope=user'
    ```
    
3. After the user is successfully authenticated, Alfred will send the code:

    ```bash
    'https://{HOST_OF_YOUR_APPLICATION}/?code={YOUR_CODE}'
    ```
4. Send the code to the backend with a post request:
    ```bash
    POST 'https://{HOST_OF_BACKEND_APPLICATION}/api/v1/auth'
    ```

    ```json
    {
      "code": "{YOUR_CODE}"
    }
    ```
   
## On the backend

5. Send a request to get a token from alfred using the code you received earlier:

   ```bash
   POST 'https://{ALFRED_HOST}/oauth/token'
   ```
   
   with body:
   
   ```json
   {
     "grant_type": "authorization_code",
     "code": "{YOUR_CODE}",
     "client_id": "{UID_OF_YOUR_APPLICATION}",
     "client_secret": "{SECRET_OF_YOUR_APPLICATION}",
     "redirect_uri": "{REDIRECT_URI_OF_YOUR_APPLICATION}",
     "scope": "user"
   }
   ```

    
6. Submit a request to obtain user data from Alfred:

    ```bash
    GET 'https://{ALFRED_HOST}/api/v1/users/me'
    ```
    
    with header:

    ```json
    {
      "authorization": "Bearer #{YOUR_CODE}"
    }
    ```
    
    After that, you will receive data about the user in json format, like this:
    
    ```json
    {
      "id": 1,
      "uid": "1130004065675965",
      "first_name": "John",
      "last_name": "Doe",
      "email": "john.doe@cybergizer.com",
      "dob": "2000-01-01",
      "avatar": "https://{ALFRED_HOST}/rails/active_storage/database/....jpg"
    } 
    ```
    
    Use this data to create a user in your client application.


## Documentation

[Here](https://github.com/cybergizer-hq/alfred/wiki) you will find more information about Alfred

## Installation

Clone repository

```bash
git clone git@github.com:cybergizer-hq/alfred.git
```

Run configuration commands

```bash
bundle install
rails db:create db:migrate
```

Run rails server

```bash
rails s
```

Run specs

```bash
rspec spec
```

## Configuration

Alfred uses the following gems:

| Environment | Version |
| ------ | ------ |
| Ruby | 2.7.1 |
| Rails | 6.0.2 |
| [Omniauth](https://github.com/omniauth/omniauth) | 1.9 |
| [Omniauth-discord](https://github.com/adaoraul/omniauth-discord) | - |
| [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) | 5.3 |
| [Doorkeeper-openid_connect](https://github.com/doorkeeper-gem/doorkeeper-openid_connect) | - |
| [Devise](https://github.com/heartcombo/devise) | 4.7 |

## Getting started

If you want to implement Alfred using Devise in your application follow the instructions.

Set up Devise in your application. You can use the official [guide](https://github.com/heartcombo/devise#getting-started).

Then add the following line to your Gemfile:

```ruby
gem 'omniauth-alfred', git: 'https://github.com/cybergizer-hq/omniauth-alfred', branch: 'master'
```

Run:

```bash
bundle install
```

Update config/initializers/devise.rb with omiauth config:

```ruby
config.omniauth :alfred, ENV.fetch('ALFRED_KEY', nil), ENV.fetch('ALFRED_SECRET', nil), scope: 'user'
```

`ALFRED_KEY` - uid of your Alfred application

`ALFRED_SECRET` - secret of your Alfred application

#### Add Routes and Controller

Add omniauth callbacks to config/routes.rb:

```ruby
devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
```

And create new controller for handle callback:

```ruby
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def alfred
    @user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect @user
  end
end
```

#### Add Support Omniauth to Your Model

Add uid and provider fields to users table:

```bash
rails g migration AddProviderAndUidToUsers provider uid
bundle exec rake db:migrate
```

Add omniauthable module and from_omniauth class method to the model:

```ruby
class User < ApplicationRecord
   devise :database_authenticatable, :registerable,
         :rememberable, :validatable, :omniauthable, omniauth_providers: [:alfred]
  
  def self.from_omniauth(auth)
    if (user = find_by_email(auth.info.email))
      return user if user.uid

      user.update(provider: auth.provider, uid: auth.uid)
      user
    else
      where(provider: auth.provider, uid: auth.uid).first
    end
  end
end
```
