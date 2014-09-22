module TempoIQ
  # Selection is a core concept that defines how you can retrieve
  # a group of related objects by common metadata. For Device and
  # Sensor selection, it is primarily used to drive Device searching
  # (Client#list_devices) and for driving reads (Client#read).
  #
  # TempoIQ currently maps selection onto the following domain objects
  #
  # - Device
  # - Sensor
  #
  # TempoIQ currently supports filtering objects by the following metadata:
  #
  # ==== Simple selectors:
  #
  # - +key+
  # - +attribute_key+
  # - +attributes+
  #
  # ==== Compound selectors:
  # - +or+
  # - +and+
  #
  # ==== Simple Examples
  #
  #    # Select devices with the key 'heatpump4549' (should return an Array of size 1)
  #    {:devices => {:key => 'heatpump4549'}}
  #
  #    # Select devices that are in buildings
  #    {:devices => {:attribute_key => 'building'}}
  #
  #    # Select devices that are in building '445-w-erie'
  #    {:devices => {:attributes => {'building' => '445-w-erie'}}}
  #
  #    # Select devices in buildings that have TX455 model sensors
  #    {:devices => {:attribute_key => 'building'},
  #     :sensors => {:attributes => {'model' => 'TX455'}}}
  #
  # ==== Compound examples
  #
  #    # Select devices with key 'heatpump4549' or 'heatpump5789'
  #    {:devices => {:or => [{:key => 'heatpump4549'}, {:key => 'heatpump5789'}]}}
  #
  #    # Select devices in buildings in the Evanston region
  #    {:devices => {:and => [{:attribute_key => 'building'}, {:attributes => {'region' => 'Evanston'}}]}}
  class Selection
    attr_reader :select, :filter

    def initialize(select, filter = {})
      @select = select
      @filter = filter
    end

    def to_hash
    end
  end
end
