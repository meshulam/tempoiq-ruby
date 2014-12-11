module TempoIQ
  class Single
    attr_reader :name, :function, :timestamp, :include_selection
    attr_accessor :include_selection

    def initialize(function, timestamp = nil, include_selection = false)
      @name = "single"
      @include_selection = include_selection
      @function = function
      @timestamp = timestamp
    end

    def to_hash
      hash = {
        "function" => function,
        "include_selection" => include_selection
      }
      hash["timestamp"] = timestamp.iso8601(3) if timestamp
      hash
    end
  end
end
