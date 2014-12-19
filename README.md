# TempoIQ Ruby Library

## Installation

The TempoIQ Ruby library makes calls to the [TempoIQ API](https://tempoiq.com/). The module is available on rubygems.org as [tempoiq](https://rubygems.org/gems/tempoiq):

    gem install tempoiq

You can also check out this repository and install locally:

    git clone https://github.com/TempoIQ/tempoiq-ruby.git
    cd tempoiq-ruby/
    gem build tempoiq.gemspec
    gem install tempoiq-<version>.gem


## Quickstart

```ruby
require 'tempoiq'

client = TempoIQ::Client.new('key', 'secret', 'myco.backend.tempoiq.com')
client.create_device('device1')
client.list_devices.to_a
```

For more example usage, see the Client ruby docs.

## Test Suite

To run the test suite against local stubs:

```
rake
```

If you'd like to run the test suite against an actual live backend,
edit `test/integration/integration-credentials.yml`, and run:

```
rake test:integration
```
