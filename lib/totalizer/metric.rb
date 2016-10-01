module Totalizer
  class Metric
    attr_accessor :model, :date, :duration, :filter, :map, :ids, :value

    def initialize params
      self.model = params[:model]
      self.date = params[:date] || DateTime.now
      self.duration = params[:duration] || 7
      self.filter = params[:filter]
      self.map = params[:map] || 'id'
      validate_attributes!
    end

    def attributes
      { model: model, date: date, duration: duration, filter: filter, map: map }
    end

    def end_date
      date
    end

    def start_date
      date - duration.days
    end

    def ids
      @ids ||= calculate(created_at: start_date..end_date)
    end

    def value
      ids.size
    end

    def start_ids
      @start_ids ||= calculate(["created_at < ?", start_date])
    end

    def start
      start_ids.size
    end

    def finish_ids
      @finish_ids ||= calculate(["created_at < ?", end_date])
    end

    def finish
      finish_ids.size
    end

    def rate
      start == 0 ? 0 : (finish - start).to_f / start.to_f
    end

    private

    def calculate where
      model.where(filter).where(where).map { |object| object.send(map) }.uniq
    end

    def validate_attributes!
      raise Errors::InvalidModel if model.nil?
      raise Errors::InvalidDate unless date.kind_of?(DateTime)
      raise Errors::InvalidDuration unless duration.kind_of?(Integer)
    end
  end
end
