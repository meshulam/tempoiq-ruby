module TempoIQ
  class Query
    attr_reader :search, :action, :pipeline

    def initialize(search, action, pipeline = nil)
      @search = search
      @action = action
      @pipeline = pipeline
    end

    def to_hash
      hash = {
        "search" => search.to_hash,
        action.name => action.to_hash
      }
      hash["fold"] = pipeline.to_hash if pipeline
      hash
    end
  end
end
