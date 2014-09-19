module TempoIQ
  class Selection
    attr_reader :select, :filter

    def initialize(select, filter = {})
      @select = select
      @filter = filter
    end

    def to_hash
    end
  end
end
