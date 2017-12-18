# Pragma::Migration

This is an experiment at implementing [Stripe-style API versioning](https://stripe.com/blog/api-versioning).

There's nothing here yet except for code samples of the desired outcome.

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
      
      # The `up` method is called when a client on an old version makes a request, and should
      # convert the request into a format that can be consumed by the operation.
      def up(request)
        request.merge('created_at' => Time.parse(request['created_at']).to_i)
      end
      
      # The `down` method is called when a response is sent to a client on an old version, and
      # convert the response into a format that can be consumed by the client.
      def down(response)
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

As you might imagine, Semantic Versioning doesn't make much sense when you adopt API migrations,
because there are no breaking changes anymore. In some occasions, you might still want to adopt
Semantic Versioning and just change the concept of what a breaking change is (e.g. renaming an
API property is not breaking anymore!).

## FAQs

**Why are the migrations so low-level?**

Admittedly, the code for migrations is very low-level: you are interacting with requests and 
responses directly, rather than using contracts and decorators. Unfortunately, so far we have been 
unable to come up with an abstraction that will not blow up at the first edge case. We are still 
experimenting here - ideas are welcome! 

**What are the drawbacks of API migrations?**

If you are used to ActiveRecord migrations, then you might be tempted to use this very freely.
However, API migrations are very different from DB migrations: DB migrations are run once and then
forgotten forever, API migrations are executed on _every request_ as long as clients are running on
an outdated version of your API. This means that API migrations should be considered an active,
evolving part of your codebase that you will have to maintain over time.

**What is the impact on performance?**

No idea yet, but if others do it, we should be able to do it too. Stay tuned!

**Are you out of your mind?**

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

- [ ] Side effects flag (`has_side_effects` in migration)
- [ ] Migration descriptions (to generate docs etc.)
- [ ] Proof of Concept
- [ ] Abstraction to deal with decorators/contracts directly
- [ ] Details on different versioning schemes (release dates, semver)
