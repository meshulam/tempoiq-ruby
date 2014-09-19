module TempoIQ
  class Pipeline
    attr_reader :functions

    def initialize
      @functions = []
    end

    def aggregate(function)
      functions << {
        "name" => "aggregation",
        "arguments" => [function.to_s]
      }
    end

    def rollup(period, function, start)
      functions << {
        "name" => "rollup",
        "arguments" => [
                        function.to_s,
                        period,
                        start.iso8601(3)
                       ]
      }
    end

    def interpolate(period, interpolation_function, start, stop)
      functions << {
        "name" => "interpolate",
        "arguments" => [
                        interpolation_function.to_s,
                        period,
                        start.iso8601(3),
                        stop.iso8601(3)
                       ]
      }
    end

    def to_hash
      {
        "functions" => functions
      }
    end
  end
end

