module TempoIQ
  class Selection
    attr_reader :select, :filter

    def initialize(select, filter = {})
      @select = select
      @filter = filter
    end

    def to_hash
      {
        "search" => {
          "select" => select,
          "filters" => filter
        },
        "find" => {
          "quantifier" => "all"
        }
      }
    end
  end
end
