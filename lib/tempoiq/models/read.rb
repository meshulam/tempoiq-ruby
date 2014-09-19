module TempoIQ
  class Read
    attr_reader :name, :start, :stop

    def initialize(start, stop)
      @name = "read"
      @start = start
      @stop = stop
    end

    def to_hash
      {
        "start" => start.iso8601(3),
        "stop" => stop.iso8601(3)
      }
    end
  end
end
