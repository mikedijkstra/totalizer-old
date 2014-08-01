module Totalizer
  class Funnel
    def initialize params
      @params = params
      validate!
    end

    def metrics
      @params[:metrics]
    end

    def steps
      steps = []
      metrics.each_with_index do |metric, index|
        previous_step = steps[index - 1]
        if previous_step
          ids = metric.ids.select { |id| previous_step.ids.include? id }
        else
          ids = metric.ids
        end
        value = ids.count
        change = if previous_step then (ids.count.to_f/previous_step.ids.count.to_f).round(2) end
        steps << Step.new(title: metric.title, value: value, change: change, ids: ids)
      end
      steps
    end

    def title
      @params[:title]
    end

    private

    def validate!
      if metrics.empty?
        raise Errors::InvalidData
      end
    end
  end
end
