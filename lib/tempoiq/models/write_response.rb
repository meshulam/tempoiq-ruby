module TempoIQ
  # WriteResponse is used to track the status of a write. Because writes
  # are bulk in nature (writing to multiple devices and sensors at once),
  # there are instances where some writes device writes may succeed and
  # some might fail in the same write call.
  #
  # [High level introspection]
  #   - #success?
  #   - #partial_success?
  #
  # [Device level introspection]
  #   - #failures
  #   - #created
  #   - #existing
  #   - #modified
  class WriteResponse
    attr_reader :status

    def initialize(status = nil)
      @status = status
    end

    # Was the write a total success?
    def success?
      status.each do |key,device_status|
        if device_status['successful'] == false
          return false
        end
      end
      true
    end

    # Did the write have partial failures?
    def partial_success?
      !success?
    end

    # Retrieve the failures, key => message [Hash]
    def failures
      status.select { |device_key, v| v["successful"] == false }
    end

    # Devices that already existed before the write
    def existing
      status.select { |device_key, v| v["device_state"] == "existing" }
    end

    # Devices that were created during the write
    def created
      status.select { |device_key, v| v["device_state"] == "created" }
    end

    # Devices that were modified (eg - sensors added) during the write
    def modified
      status.select { |device_key, v| v["device_state"] == "modified" }
    end
  end
end
