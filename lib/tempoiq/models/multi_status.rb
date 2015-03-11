module TempoIQ
  # MultiStatus is used in cases where an operation might partially succeed
  # and partially fail. It provides several helper functions to introspect the
  # failure and take appropriate action. (Log failure, resend DataPoints, etc.)
  class MultiStatus
    attr_reader :status

    def initialize(status = nil)
      @status = status
    end

    # Was the request a total success?
    def success?
      status.each do |key,device_status|
        if device_status['successful'] == false
          return false
        end
      end
      true
    end

    # Did the request have partial failures?
    def partial_success?
      !success?
    end

    # Retrieve the failures, key => message [Hash]
    def failures
      status.select { |device_key, v| v["successful"] == false }
    end

    def existing
      status.select { |device_key, v| v["device_state"] == "existing" }
    end

    def created
      status.select { |device_key, v| v["device_state"] == "created" }
    end

    def modified
      status.select { |device_key, v| v["device_state"] == "modified" }
    end
  end
end
