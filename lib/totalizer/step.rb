module Totalizer
  class Step
    attr_accessor :start_ids, :end_ids

    def initialize start_ids, end_ids
      self.start_ids = start_ids
      self.end_ids = end_ids
      validate!
    end

    def rate
      (finish.to_f/(start.to_f.nonzero? || 1)).round(2)
    end

    def ids
      @ids ||= calculate
    end

    def start
      start_ids.size
    end

    def finish
      ids.size
    end

    private

    def validate!
      raise Errors::InvalidData unless start_ids.kind_of?(Array) && end_ids.kind_of?(Array)
    end

    def calculate
      start_ids & end_ids
    end
  end
end
