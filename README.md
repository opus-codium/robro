# Robro

**Robro**, _Robotized brower_, a tool to ease some tasks automation that needs a _real_ browser.

Technically, `robro` is a CLI that starts a browser and provides some helpers to drive it.

**Robro** is designed to run _user scripts_, specialized for the wanted automation. Out of the box, `robro` only provides a `browse` command to starts a browser, visit an URL and drop a ruby shell.

## Usage

Built-in command: `browse` will open the provided URL than simply drop a ruby shell (_byebug_).

```
robro browse https://example.com
```

Its useful to design your own _user script_, see below.

## User scripts

_User scripts_ are ruby files that provide new commands, designed to use the robotized browser.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opus-codium/robro.

