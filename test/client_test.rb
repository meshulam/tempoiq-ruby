require 'tempoiq/client'

module ClientTest
  def test_initialize
    client = TempoIQ::Client.new("key", "secret", "backend.tempoiq.com")
    assert_equal("key", client.key)
    assert_equal("secret", client.secret)
    assert_equal("backend.tempoiq.com", client.host)
    assert(client.secure)
  end

  def test_create_device
    client = get_client
    stubbed_body = {
      'key' => 'stubbed_key',
      'name' => 'stubbed_name',
      'attributes' => 'stubbed_attributes',
      'sensors' => []
    }
    client.remoter.stub(:post, "/v2/devices", 200, JSON.dump(stubbed_body))

    device = client.create_device('stubbed_key', 'stubbed_name', 'stubbed_attributes')

    assert_equal('stubbed_key', device.key)
    assert_equal('stubbed_name', device.name)
    assert_equal('stubbed_attributes', device.attributes)
    assert_equal([], device.sensors)
  end
end
