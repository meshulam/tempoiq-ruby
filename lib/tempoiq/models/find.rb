module TempoIQ
  class Find
    attr_reader :name

    def initialize
      @name = "find"
    end

    def to_hash
      {
        "quantifier" => "all"
      }
    end
  end
end
