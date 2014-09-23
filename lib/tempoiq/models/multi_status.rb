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
      status.nil?
    end

    # Did the request have partial failures?
    def partial_success?
      !success?
    end

    # Retrieve the failures, key => message [Hash]
    def failures
      Hash[status.map { |device_key, v| [device_key, v["message"]] } ]
    end
  end
end
