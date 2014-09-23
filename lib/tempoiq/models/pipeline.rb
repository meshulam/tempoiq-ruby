module TempoIQ
  # Used to transform a stream of devices using a list of
  # function transformations.
  class Pipeline
    attr_reader :functions

    def initialize
      @functions = []
    end

    # DataPoint aggregation
    #
    # * +function+ [Symbol] - Function to aggregate by. One of:
    #   * count - The number of datapoints across sensors
    #   * sum - Summation of all datapoints across sensors
    #   * mult - Multiplication of all datapoints across sensors
    #   * min - The smallest datapoint value across sensors
    #   * max - The largest datapoint value across sensors
    #   * stddev - The standard deviation of the datapoint values across sensors
    #   * ss - Sum of squares of all datapoints across sensors
    #   * range - The maximum value less the minimum value of the datapoint values across sensors
    #   * percentile,N (where N is what percentile to calculate) - Percentile of datapoint values across sensors
    def aggregate(function)
      functions << {
        "name" => "aggregation",
        "arguments" => [function.to_s]
      }
    end

    # Rollup a stream of DataPoints to a given period
    #
    # * +period+ [String] - The duration of each rollup. Specified by:
    #   * A number and unit of time: EG - '1min' '10days'.
    #   * A valid ISO8601 duration
    # * +function+ [Symbol] - Function to rollup by. One of:
    #   * count - The number of datapoints in the period
    #   * sum - Summation of all datapoint values in the period
    #   * mult - Multiplication of all datapoint values in the period
    #   * min - The smallest datapoint value in the period
    #   * max - The largest datapoint value in the period
    #   * stddev - The standard deviation of the datapoint values in the period
    #   * ss - Sum of squares of all datapoint values in the period
    #   * range - The maximum value less the minimum value of the datapoint values in the period
    #   * percentile,N (where N is what percentile to calculate) - Percentile of datapoint values in period
    # * +start+ [Time] - The beginning of the rollup interval
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

    # Interpolate missing data within a sensor, based on
    #
    # * +period+ [String] - The duration of each rollup. Specified by:
    #   * A number and unit of time: EG - '1min' '10days'.
    #   * A valid ISO8601 duration
    # * +function+ [Symbol] - The type of interpolation to perform. One of:
    #   * linear - Perform linear interpolation
    #   * zoh - Zero order hold interpolation
    # * +start+ [Time] - The beginning of the interpolation range
    # * +stop+ [Time] - The end of the interpolation range
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

