# ActionSerializers

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'action_serializers'

Add an initializer:

```ruby
# config/initializers/action_serializers

ActionSerializers.configure do |config|
  config.global_metadata = { api_version: "08-01-2014" }
  config.profile_url = "https://www.bobsburgers.local/profile.txt"
end
```

## Usage

TODO: In-depth

```ruby
# app/serializers/accounts/show_serializer.rb

module Accounts
  class ShowSerializer < ActionSerializers::Base

    resource :account
    linked :recipes

    metadata :nutritional_guide

    private

    def metadata_nutritional_guide
      { most:  [:candy, :chocolate],
        least: [:broccoli, :carrots] }
    end

  end
end
```

## TODO

1. Spec configuration
2. Benchmarks
3. Include `links` in the document
4. Optimal handling for only/except options
5. When necassary, build a relation for linked resources
6. Coffee

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
