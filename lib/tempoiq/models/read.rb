module TempoIQ
  class Read
    attr_reader :name, :start, :stop, :limit

    def initialize(start, stop, limit = nil)
      @name = "read"
      @start = start
      @stop = stop
      @limit = limit
    end

    def to_hash
      hash = {
        "start" => start.iso8601(3),
        "stop" => stop.iso8601(3)
      }
      hash["limit"] = limit if limit
      hash
    end
  end
end
