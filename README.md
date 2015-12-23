# TDUserGem
#### *A Ruby wrapper for TDUser.*

This ruby gem wraps the [TDUser] functionality, making its usage easier. You can improve your
development performance by using this gem, because you will only have to handle with friendly
methods that will do the hard work for you!

## Dependencies
*TDUserGem* has the following dependencies:
-  [httparty] 0.13.5
-  [activesupport] 4.2.3

## Including it in your project

In order to use this gem in your application, add the following lines to your Gemfile:

```ruby
gem 'td-users', git: 'https://github.com/talosdigital/TDUserGem.git'
```

And then execute:

    $ bundle

## Setup

You are almost ready to use the gem. Before using any *TDUserGem* method you should perform some
configurations as follows:

- **base_url**: Base URL where your [TDUser] server is running.
- **application_secret**: Your [TDUser] application secret (you can set it in the [TDUser] server
  configuration)
- **user_url**: Path where the *User* module is running *(default to '/api/v1/user')*
- **auth_url**: Path where the *Auth* module is running *(default to '/api/v1/auth')*

> Refer to the [configuration file](/lib/td/users/configuration.rb) to see all configurable keys.

*Example:* ``my_app/config/initializers/td_user_gem_config.rb``
```ruby
TD::Users.configure do |config|
  config.base_url               = 'http://tduser.com:9001'
  config.application_secret     = '0m6_7h15_15_v3ry_53cr37'
end
```
## Usage examples
For instance, if you want to create an **User**, you could use the following methods:

```ruby
user = TD::Users::User.new(first_name: 'John',
                           last_name: 'Smith',
                           birth_date: '1995-01-01',
                           email: 'john@smith.com')
user.create
```
The above command lines are equivalent to:
```ruby
TD::Users::User.create(first_name: 'John',
                       last_name: 'Smith',
                       birth_date: '1995-01-01',
                       email: 'john@smith.com')
```

There are multiple methods that could be used with an instance besides the class, for example,
the *create* and *update* methods for **User**.

You can also run all methods using the *Ruby* console or by executing `bin/console`.

[TDUser]: https://github.com/talosdigital/TDUser
[httparty]: https://github.com/jnunemaker/httparty
[activesupport]: https://rubygems.org/gems/activesupport/versions/4.2.3
