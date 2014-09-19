require 'tempoiq/client'

module ClientTest
  def setup
    delete_devices
  end

  def teardown
    delete_devices
  end

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
      'attributes' => {'attr1' => 'value1'},
      'sensors' => []
    }
    client.remoter.stub(:post, "/v2/devices", 200, JSON.dump(stubbed_body))

    device = client.create_device('stubbed_key', 'stubbed_name', 'attr1' => 'value1')

    assert_equal('stubbed_key', device.key)
    assert_equal('stubbed_name', device.name)
    assert_equal({'attr1' => 'value1'}, device.attributes)
    assert_equal([], device.sensors)
  end

  def test_delete_devices
    device = create_device

    client = get_client
    stubbed_body = {
      'deleted' => 1
    }

    client.remoter.stub(:delete, "/v2/devices", 200, JSON.dump(stubbed_body))

    summary = client.delete_devices(:devices => {:key => device.key})
    assert_equal(1, summary.deleted)
  end

  private

  def create_device
    client = get_client
    stubbed_body = {
      'key' => 'device1',
      'name' => 'My Awesome Device',
      'attributes' => {'attr1' => 'value1'},
      'sensors' => [{
                      'key' => 'sensor1',
                      'name' => 'My Sensor',
                      'attributes' => {
                        'unit' => 'F'
                      }
                    }]
    }
    client.remoter.stub(:post, "/v2/devices", 200, JSON.dump(stubbed_body))
    client.create_device('device1', 'My Awesome Device', {'attr1' => 'value1'}, TempoIQ::Sensor.new('sensor1', 'My Sensor', 'unit' => 'F'))
  end

  def delete_devices
    client = get_client
    stubbed_body = {
      'deleted' => 1
    }

    client.remoter.stub(:delete, "/v2/devices", 200, JSON.dump(stubbed_body))
    summary = client.delete_devices(:devices => :all)
  end
end
