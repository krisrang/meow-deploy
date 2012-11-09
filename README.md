# MeowDeploy

Tasks for deploying to a stack running god, rbenv and whatever rails server

Has only been tested on Ubuntu 12.04 and 12.10 with ruby 1.9.3-p286 using user-local rbenv install

## Installation

Install from rubygems:

```
gem install meow-deploy
```

## Usage

Add the library to your `Gemfile`:

```ruby
group :development do
  gem 'meow-deploy', :require => false
end
```

And load it into your deployment script `config/deploy.rb`:

```ruby
require 'meow-deploy'
```

Add necessary hooks:

```ruby
after 'deploy:restart', 'god:reload', 'god:restart'
```

Make sure you set up the PATH env variable to include rbenv paths.
For example if rbenv is installed in deployment user's home:

```ruby
set :default_environment, {
  'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
}
```

Add optional hooks for uploading your .rbenv-vars file if you're using the rbenv-vars plugin:

```ruby
after 'deploy:create_symlink', 'secrets:upload', 'secrets:symlink'
```

Create a new configuration file `config/god.conf`.

Example config - [examples/god.conf](https://github.com/krisrang/meow-deploy/blob/master/examples/god.conf).
Please refer to godrb documentation for more examples and configuration options.

## Configuration

You can modify any of the following options in your `deploy.rb` config.

- `rbenv` - Full path to rbenv. Given user is `deploy` defaults to `/home/deploy/.rbenv/bin/rbenv`
- `god_sites_path` - Directory where god configs for all apps on the server are symlinked for reloading after reboot. Given user is `deploy` defaults to `/home/deploy/sites/god`
- `god_app_path` - App-specific god.conf. Defaults to `#{current_path}/config/god.conf`.
- `bundle_flags` - Bundler flags for generating binstubs that use rbenv. Defaults to `--deployment --quiet --binstubs --shebang ruby-local-exec`
          
## License

See LICENSE file for details.
