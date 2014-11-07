require 'test/unit'

require File.join(File.dirname(__FILE__), "..", "client_test")

require 'tempoiq/remoter/stubbed_remoter'

class TestStubbedClient < Test::Unit::TestCase
  include ClientTest

  private

  def get_client(pop_stubs = false)
    TempoIQ::Client.new("key", "secret", "backend.tempoiq.com", 8080, :remoter => TempoIQ::StubbedRemoter.new(pop_stubs))
  end
end
