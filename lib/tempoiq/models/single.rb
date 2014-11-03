module TempoIQ
  class Single
    attr_reader :name
    attr_accessor :include_selection

    def initialize(include_selection = false)
      @name = "single"
      @include_selection = include_selection
    end

    def to_hash
      {
        "include_selection" => include_selection
      }
    end
  end
end
