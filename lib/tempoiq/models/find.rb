module TempoIQ
  class Find
    attr_reader :name, :limit

    def initialize(limit = nil)
      @name = "find"
      @limit = limit
    end

    def to_hash
      hash = {
        "quantifier" => "all"
      }
      hash["limit"] = limit if limit
      hash
    end
  end
end
