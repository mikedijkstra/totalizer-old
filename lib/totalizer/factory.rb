module Totalizer
  class Factory
    attr_accessor :growth_metric, :activity_metric, :vanity_metric, :date, :duration

    def initialize growth_metric, activity_metric, vanity_metric, params={}
      self.growth_metric = growth_metric
      self.activity_metric = activity_metric
      self.vanity_metric = vanity_metric
      self.date = params[:date] || DateTime.now.change(hour: 0)
      self.duration = params[:duration] || 7
      validate_attributes!
    end

    def acquisition
      growth_metric = Totalizer::Metric.new self.growth_metric.attributes.merge(date: date, duration: duration)
      AcqusitionMessage.new(growth_metric, duration)
    end

    def vanity
      vanity_metric = Totalizer::Metric.new self.vanity_metric.attributes.merge(date: date, duration: duration)
      VanityMessage.new(vanity_metric, duration)
    end

    def activation
      growth_metric = Totalizer::Metric.new self.growth_metric.attributes.merge(date: date, duration: duration)
      activity_metric = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date, duration: duration)
      step = Totalizer::Step.new growth_metric.ids, activity_metric.ids
      ActivationMessage.new(step, duration)
    end

    def activity
      activity_metric = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date, duration: duration)
      ActivityMessage.new(activity_metric, duration)
    end

    def engagement
      growth_metric = Totalizer::Metric.new self.growth_metric.attributes.merge(date: date, duration: duration)
      activity_metric = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date, duration: duration)
      EngagementMessage.new(growth_metric, activity_metric, duration)
    end

    def retention
      previous_period = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date - duration.days, duration: duration)
      this_period = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date, duration: duration)
      step = Totalizer::Step.new previous_period.ids, this_period.ids
      RetentionMessage.new(step, duration)
    end

    def churn
      growth_metric = Totalizer::Metric.new self.growth_metric.attributes.merge(date: date, duration: duration)
      previous_activity_metric = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date - duration.days, duration: duration)
      this_activity_metc = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date, duration: duration)
      ChurnMessage.new(growth_metric, previous_activity_metric, this_activity_metc, duration)
    end

    private

    def validate_attributes!
      raise Errors::InvalidMetric unless growth_metric.kind_of?(Totalizer::Metric)
      raise Errors::InvalidMetric unless activity_metric.kind_of?(Totalizer::Metric)
      raise Errors::InvalidMetric unless vanity_metric.kind_of?(Totalizer::Metric)
      raise Errors::InvalidDate unless date.kind_of?(DateTime)
      raise Errors::InvalidDuration unless duration.kind_of?(Integer)
    end
  end
end
