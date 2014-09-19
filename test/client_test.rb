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

  def test_update_device
    device = create_device
    client = get_client

    original_name = device.name
    device.name = "Updated"
    assert_not_equal(original_name, device.name)

    stubbed_body = device.to_hash
    client.remoter.stub(:put, "/v2/devices/#{device.key}", 200, JSON.dump(stubbed_body))

    updated_device = client.update_device(device)
    assert_equal(device.name, updated_device.name)
  end

  def test_get_device
    device = create_device
    client = get_client

    stubbed_body = device.to_hash
    client.remoter.stub(:get, "/v2/devices/#{device.key}", 200, JSON.dump(stubbed_body))

    found = client.get_device(device.key)

    assert_equal(device.key, found.key)
  end

  def test_list_devices
    device = create_device
    client = get_client

    stubbed_body = {
      "data" => [device.to_hash]
    }
    client.remoter.stub(:get, "/v2/devices", 200, JSON.dump(stubbed_body))

    found = client.list_devices(:devices => {:key => device.key})
    assert_equal(device.key, found.to_a.first.key)
  end

  def test_write_bulk
    device = create_device
    client = get_client
    ts = Time.utc(2012, 1, 1)

    device_key = device.key
    sensor_key = device.sensors.first.key

    client.remoter.stub(:post, "/v2/write", 200)

    result = client.write_bulk do |write|
      write.add(device_key, sensor_key, TempoIQ::DataPoint.new(ts, 1.23))
    end

    assert(result.success?)
  end

  def test_delete_device
    device = create_device
    client = get_client

    client.remoter.stub(:delete, "/v2/devices/#{device.key}", 200)

    result = client.delete_device(device.key)
    assert(result.success?)
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
