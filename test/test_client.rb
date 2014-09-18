require 'tempoiq/client'
require 'test/unit'

class TestClient < Test::Unit::TestCase
  def test_initialize
    client = TempoIQ::Client.new("key", "secret", "backend.tempoiq.com")
    
    assert_equal("key", client.key)
    assert_equal("secret", client.secret)
    assert_equal("backend.tempoiq.com", client.host)
    assert(client.secure)
  end
end
