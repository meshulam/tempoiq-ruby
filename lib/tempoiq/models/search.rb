module TempoIQ
  class Search
    attr_reader :select, :selection

    def initialize(select, selection)
      @select = select
      @selection = selection
    end

    def to_hash
      {
        "select" => select,
        "filters" => selection.to_hash
      }
    end
  end
end
