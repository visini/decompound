# decompound

> [!IMPORTANT]
> This gem is in an early stage of development. Splitting does not work yet. The API may change in the future.

A Ruby gem for splitting German compound words into their constituent parts.

```rb
require "decompound"

word = "Bodenbelag"
parts = Decompound.split(word)
# => ["boden", "belag"]
```

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add decompound
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install decompound
```

## Usage

TODO: Add usage instructions

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Release process

For each release:

1. Update `lib/decompound/version.rb`
2. Update `CHANGELOG.md`
3. Run tests and RBS validation
4. Commit with message `Prepare x.x.x release` and push
5. Run `bundle exec rake release`

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/visini/decompound>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
