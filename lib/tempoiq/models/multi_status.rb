module TempoIQ
  class MultiStatus
    attr_reader :status

    def initialize(status = nil)
      @status = status
    end

    def success?
      status.nil?
    end

    def partial_success?
      !success?
    end

    def failures
      Hash[status.map { |device_key, v| [device_key, v["message"]] } ]
    end
  end
end
