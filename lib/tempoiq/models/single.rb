module TempoIQ
  class Single
    attr_reader :name
    attr_accessor :include_selection

    def initialize(function, timestamp = nil, include_selection = false)
      @name = "single"
      @include_selection = include_selection
      @function = function
    end

    def to_hash
      {
        "function" => @function,
        "timestamp" => @timestamp,
        "include_selection" => @include_selection
      }
    end
  end
end
