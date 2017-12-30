# Pragma::Migration

[![Build Status](https://travis-ci.org/pragmarb/pragma-migration.svg?branch=master)](https://travis-ci.org/pragmarb/pragma-migration)
[![Dependency Status](https://gemnasium.com/badges/github.com/pragmarb/pragma-migration.svg)](https://gemnasium.com/github.com/pragmarb/pragma-migration)
[![Coverage Status](https://coveralls.io/repos/github/pragmarb/pragma-migration/badge.svg?branch=master)](https://coveralls.io/github/pragmarb/pragma-migration?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/e51e8d7489eb72ab97ba/maintainability)](https://codeclimate.com/github/pragmarb/pragma-migration/maintainability)

Pragma::Migration is an experiment at implementing [Stripe-style API versioning](https://stripe.com/blog/api-versioning).

**This gem is highly experimental and still under active development. Usage in a production environment is strongly discouraged.**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pragma-migration'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pragma-migration

Next, we're going to create a migration repository for our API:

```ruby
module API
  class MigrationRepository < Pragma::Migration::Repository
    # This tells the repository how to determine the current user's API version.
    determine_version_with do |request|
      # `request` here is a `Rack::Request` object. Below is the default implementation.
      request.get_header 'X-Api-Version'
    end

    # The initial version isn't allowed to have migrations, because there is nothing
    # to migrate from.
    version '2017-12-17'
  end
end
```

Finally, we will mount the migration Rack middleware. In a Rails environment, this means adding the
following to `config/application.rb`:

```ruby
module YourApp
  class Application < Rails::Application
    # ...

    config.middleware.use Pragma::Migration::Middleware, repository: API::MigrationRepository
  end
end
```

## Usage

When you start working on a new API version, you should define a new version in the repository:

```ruby
module API
  class MigrationRepository < Pragma::Migration::Repository
    determine_version_with do |request|
      request.get_header 'X-Api-Version'
    end

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
      # You can use any pattern supported by Mustermann here.
      apply_to '/articles/*'
      
      # Optionally, you can write a description for the migration, which you can use for
      # documentation and changelogs.
      describe 'Timestamps have been replaced with seconds since the epoch in the Articles API.' 
      
      # The `up` method is called when a client on an old version makes a request, and should
      # convert the request into a format that can be consumed by the operation.
      def up
        request.merge('created_at' => Time.parse(request['created_at']).to_i)
      end
      
      # The `down` method is called when a response is sent to a client on an old version, and
      # convert the response into a format that can be consumed by the client.
      def down
        response.merge('created_at' => Time.at(response['created_at']).iso8601)
      end
    end
  end
end
```

Now, you will just add your migration to the repository:

```ruby
module API
  class MigrationRepository < Pragma::Migration::Repository
    determine_version_with do |request|
      request.get_header 'X-Api-Version'
    end

    version '2017-12-17'

    version '2100-01-01', [
      API::Migration::ChangeTimestampsToUnixEpochs,
    ]
  end
end
```

As you can see, the migration allows API requests generated by outdated clients to run on the new
version. You don't have to implement ugly conditionals everywhere in your API: all the changes are
neatly contained in the API migrations.

There is no limit to how many migrations or versions you can have. There's also no limit on how old 
your clients can be: even if they are 10 versions behind, the migrations for all versions will be 
applied in order, so that the clients are able to interact with the very latest version without even 
knowing it!

### Using migrations to contain side effects

In some cases, migrations are more complex than a simple update of the request and response. 

Let's take this example scenario: you are building a blog API and you are working on a new version 
that automatically sends an email to subscribers when a new article is sent, whereas the current 
version requires a separate API call to accomplish this. Since you don't want to surprise existing 
users with the new behavior, you only want to do this when the new API version is being used.

You can use a no-op migration like the following for this:

```ruby
module API
  module Migration
    module V1
      class NotifySubscribersAutomatically < Pragma::Migration::Base
        describe 'Subscribers are now notified automatically when a new article is published.'
      end
    end
  end
end
```

Then, in your operation, you will only execute the new code if the migration has been executed (i.e.
the user's version is greater than the migration's version):

```ruby
module API
  module V1
    module Article
      module Operation
        class Create < Pragma::Operation::Create
          step :notify_subscribers!

          def notify_subscribers!(options)
            return unless migrated?(Migration::NotifySubscribersAutomatically)

            # Notify subscribers here...
          end
        end
      end
    end
  end
end
```

### Implementing complex version tracking

TODO: Tutorial on how to implement API version tracking like Stripe (first request stores API 
version on user profile, subsequent calls use that version).

## FAQs

### Why are the migrations so low-level?

Admittedly, the code for migrations is very low-level: you are interacting with requests and 
responses directly, rather than using contracts and decorators. Unfortunately, so far we have been 
unable to come up with an abstraction that will not blow up at the first edge case. We are still 
experimenting here - ideas are welcome! 

### What are the drawbacks of API migrations?

If you are used to ActiveRecord migrations, then you might be tempted to use this very freely.
However, API migrations are very different from DB migrations: DB migrations are run once and then
forgotten forever, API migrations are executed on _every request_ as long as clients are running on
an outdated version of your API. This means that API migrations should be considered an active,
evolving part of your codebase that you will have to maintain over time.

### What is the impact on performance?

No idea yet, but if others do it, we should be able to do it too. Stay tuned!

### Are you out of your mind?

Possibly, [but we're not the only ones](https://stripe.com/blog/api-versioning).

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

## Todos

- [ ] Prevent initial version from having migrations
- [ ] Class-based pattern matching (`#apply_to`)
- [ ] Abstraction to deal with decorators/contracts directly
- [ ] Include in Rails starter (and test)
- [ ] Implement `Repository#migrated?` and operation hooks
