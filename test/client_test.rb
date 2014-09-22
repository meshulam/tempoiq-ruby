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

  def test_get_device_not_found
    client = get_client

    client.remoter.stub(:get, "/v2/devices/not_found", 404)

    not_found = client.get_device("not_found")
    assert_nil(not_found)
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

  def test_write_bulk_no_params
    client = get_client

    assert_raise(TempoIQ::ClientError) do
      client.write_bulk
    end
  end

  def test_write_device
    device = create_device
    client = get_client
    ts = Time.utc(2012, 1, 1)

    device_key = device.key
    sensor_key = device.sensors.first.key

    client.remoter.stub(:post, "/v2/write", 200)

    result = client.write_device(device_key, ts, sensor_key => 1.23)

    assert(result.success?)
  end

  def test_read_with_pipeline
    device = create_device
    client = get_client
    ts = Time.utc(2012, 1, 1, 1)
    start = Time.utc(2012, 1, 1)
    stop = Time.utc(2012, 1, 2)

    device_key = device.key
    sensor_key1 = device.sensors[0].key
    sensor_key2 = device.sensors[1].key
    
    client.remoter.stub(:post, "/v2/write", 200)

    write_result = client.write_device(device_key, Time.utc(2012, 1, 1, 1), sensor_key1 => 4.0, sensor_key2 => 2.0)
    assert(write_result.success?)
    write_result = client.write_device(device_key, Time.utc(2012, 1, 1, 2), sensor_key1 => 4.0, sensor_key2 => 2.0)
    assert(write_result.success?)

    selection = {
      :devices => {:key => device_key}
    }

    stubbed_read = {
      "data" => [
                 {
                   "t" => ts.iso8601(3),
                   "data" => {
                     device_key => {
                       "mean" => 6.0
                     }
                   }
                 }
                ]
    }
    client.remoter.stub(:get, "/v2/read", 200, JSON.dump(stubbed_read))

    rows = client.read(selection, start, stop) do |pipeline|
      pipeline.rollup("1day", :sum, start)
      pipeline.aggregate(:mean)
    end.to_a

    assert_equal(1, rows.size)
    assert_equal(6.0, rows[0].value(device.key, "mean"))
  end

  def test_read_with_interpolation
    device = create_device
    client = get_client
    start = Time.utc(2012, 1, 1, 1, 0, 0, 0)
    stop = Time.utc(2012, 1, 1, 1, 0, 20, 0)

    device_key = device.key
    sensor_key = device.sensors[0].key

    client.remoter.stub(:post, "/v2/write", 200)

    write_result = client.write_device(device_key, Time.utc(2012, 1, 1, 1, 0, 5, 0), sensor_key => 4.0)
    assert(write_result.success?)
    write_result = client.write_device(device_key, Time.utc(2012, 1, 1, 1, 0, 10, 0), sensor_key => 8.0)
    assert(write_result.success?)

    selection = {
      :devices => {:key => device_key}
    }

    stubbed_read = {
      "data" => [
                 {
                   "t" => Time.utc(2012, 1, 1, 1, 0, 5, 0),
                   "data" => {
                     device_key => {
                       sensor_key => 4.0
                     }
                   }
                 },
                 {
                   "t" => Time.utc(2012, 1, 1, 1, 0, 6, 0),
                   "data" => {
                     device_key => {
                       sensor_key => 4.8
                     }
                   }
                 },
                 {
                   "t" => Time.utc(2012, 1, 1, 1, 0, 7, 0),
                   "data" => {
                     device_key => {
                       sensor_key => 5.6
                     }
                   }
                 },
                 {
                   "t" => Time.utc(2012, 1, 1, 1, 0, 8, 0),
                   "data" => {
                     device_key => {
                       sensor_key => 6.4
                     }
                   }
                 },
                 {
                   "t" => Time.utc(2012, 1, 1, 1, 0, 9, 0),
                   "data" => {
                     device_key => {
                       sensor_key => 7.2
                     }
                   }
                 },
                 {
                   "t" => Time.utc(2012, 1, 1, 1, 0, 10, 0),
                   "data" => {
                     device_key => {
                       sensor_key => 8.0
                     }
                   }
                 }
                ]
    }

    client.remoter.stub(:get, "/v2/read", 200, JSON.dump(stubbed_read))

    rows = client.read(selection, start, stop) do |pipeline|
      pipeline.interpolate("PT1S", :linear, start, stop)
    end.to_a

    assert_equal(6, rows.size)
  end

  def test_read_without_pipeline
    device = create_device
    client = get_client
    ts = Time.utc(2012, 1, 1, 1)
    start = Time.utc(2012, 1, 1)
    stop = Time.utc(2012, 1, 2)

    device_key = device.key
    sensor_key1 = device.sensors[0].key
    sensor_key2 = device.sensors[1].key

    client.remoter.stub(:post, "/v2/write", 200)

    write_result = client.write_device(device_key, ts, sensor_key1 => 4.0, sensor_key2 => 2.0)
    assert(write_result.success?)

    selection = {
      :devices => {:key => device_key}
    }

    stubbed_read = {
      "data" => [
                 {
                   "t" => ts.iso8601(3),
                   "data" => {
                     device_key => {
                       sensor_key1 => 4.0,
                       sensor_key2 => 2.0
                     }
                   }
                 }
                ]
    }
    client.remoter.stub(:get, "/v2/read", 200, JSON.dump(stubbed_read))

    rows = client.read(selection, start, stop).to_a

    assert_equal(1, rows.size)
    assert_equal(4.0, rows[0].value(device.key, sensor_key1))
    assert_equal(2.0, rows[0].value(device.key, sensor_key2))
  end

  def test_delete_device
    device = create_device
    client = get_client

    client.remoter.stub(:delete, "/v2/devices/#{device.key}", 200)

    deleted = client.delete_device(device.key)
    assert_equal(true, deleted)
  end

  private

  def create_device
    client = get_client
    stubbed_body = {
      'key' => 'device1',
      'name' => 'My Awesome Device',
      'attributes' => {'building' => '1234'},
      'sensors' => [
                    {
                      'key' => 'sensor1',
                      'name' => 'My Sensor',
                      'attributes' => {
                        'unit' => 'F'
                      },
                    },
                    {
                      'key' => 'sensor2',
                      'name' => 'My Sensor2',
                      'attributes' => {
                        'unit' => 'C'
                      }
                    }
                   ]
    }
    client.remoter.stub(:post, "/v2/devices", 200, JSON.dump(stubbed_body))
    client.create_device('device1', 'My Awesome Device', {'building' => '1234'},
                         TempoIQ::Sensor.new('sensor1', 'My Sensor', 'unit' => 'F'),
                         TempoIQ::Sensor.new('sensor2', 'My Sensor2', 'unit' => 'C'))
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
