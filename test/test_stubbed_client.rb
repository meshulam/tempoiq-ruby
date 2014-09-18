require 'test/unit'

require_relative './client_test'

require 'tempoiq/remoter/stubbed_remoter'

class TestStubbedClient < Test::Unit::TestCase
  include ClientTest

  private

  def get_client
    TempoIQ::Client.new("key", "secret", "backend.tempoiq.com", 8080, :remoter => TempoIQ::StubbedRemoter.new)
  end
end
