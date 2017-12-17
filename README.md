# Pragma::Migration

This is an experiment at implementing [Stripe-style API versioning](https://stripe.com/blog/api-versioning).

There's nothing here yet except for desired final code examples.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pragma-migration'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pragma-migration

Next, we're going to inform Pragma of the API version requested by a client:

```ruby
module API
  module V1
    class ResourceController < ApplicationController
      include Pragma::Rails::ResourceController

      private

      def current_version
        # Latest version is assumed if this returns nil.
        request.headers['Api-Version'] || current_user&.version
      end
    end
  end
end
```

Finally, we'll create a migration repository for our API. This _must_ be placed at the root level
of your API (e.g. `API`). This is basically a list of your API versions and the migrations 
introduced for each. For now, we'll just define our initial version.

```ruby
module API
  class MigrationRepository < Pragma::Migration::Repository
    # The initial version of your empty isn't allowed to have migrations, because there is nothing
    # to migrate from.
    version '2017-12-17'
  end
end
```

Note that there's no restriction on the format of version numbers - just make sure they can be 
sorted alphabetically. We recommend release dates. [Semantic Versioning](https://semver.org/) is 
another option, but you will soon see that it stops to make sense with this approach to versioning. 

## Usage

When you start working on a new API version, you should define a new version in the repository:

```ruby
module API
  class MigrationRepository < Pragma::Migration::Repository
    version '2017-12-17'
    
    # We will give this a date very far into the future for now, since we don't know the release
    # date yet. 
    version '2100-01-01', [
      # Add migrations here...
    ]
  end
end
```

Suppose you are working on a new API version and you decide to start using seconds since the epoch 
instead of timestamps. In order to support users who are on an older version of the API, you will
need to do the following:

- convert their input timestamps into UNIX epochs before passing them to your code;
- convert your UNIX epochs to timestamps before sending the HTTP response.

To accomplish it, you might write a new migration like this:

```ruby
module API
  module Migration
    class ChangeTimestampsToUnixEpochs < Pragma::Migration::Base
      # Here you can specify a namespace or a specific operation.
      apply_to API::Article::Operation
      
      def up(request)
        request.merge('created_at' => Time.parse(request['created_at']).to_i)
      end
      
      def down(response)
        response.merge('created_at' => Time.at(response['created_at']).iso8601)
      end
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run 
the tests. You can also run `bin/console` for an interactive prompt that will allow you to 
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new 
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which 
will create a git tag for the version, push git commits and tags, and push the `.gem` file to 
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pragmarb/pragma-migration.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
