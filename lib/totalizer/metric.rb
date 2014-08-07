module Totalizer
  class Metric
    def initialize params
      @params = params
      validate!
      calculate!
    end

    def change
      value - previous_value
    end

    def change_label
      (change > 0 ? "+#{change}" : change).to_s
    end

    def duration
      @params[:duration] || 7
    end

    def filter
      @params[:filter]
    end

    def ids
      @ids
    end

    def map
      @params[:map] || 'id'
    end

    def model
      @params[:model]
    end

    def previous_ids
      @previous_ids
    end

    def previous_value
      previous_ids.size
    end

    def start_date
      @params[:start_date] || Date.today.beginning_of_day
    end

    def title
      @params[:title]
    end

    def value
      ids.size
    end

    private

    def build_date_range duration_multiplier
      start_date - (duration * duration_multiplier).days..start_date - (duration * (duration_multiplier - 1)).days
    end

    def calculate!
      @ids = calculate
      @previous_ids = calculate(2)
    end

    def calculate duration_multiplier=1
      model.where(filter).where(created_at: build_date_range(duration_multiplier)).map { |object| object.send(map) }.uniq
    end

    def validate!
      if model.nil?
        raise Errors::InvalidData
      end
    end
  end
end
