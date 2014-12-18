# TempoIQ HTTP Ruby Client

## Installation

```
gem build tempoiq.gemspec
gem install tempoiq-<version>.gem
```

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

