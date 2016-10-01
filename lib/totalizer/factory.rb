module Totalizer
  class Factory
    attr_accessor :growth_metric, :activity_metric, :date, :acquisition_duration, :activation_duration, :engagement_duration, :retention_duration, :churn_duration

    def initialize params
      self.growth_metric = params[:growth_metric]
      self.activity_metric = params[:activity_metric]
      self.date = params[:date] || DateTime.now
      self.acquisition_duration = params[:acquisition_duration] || 7
      self.activation_duration = params[:activation_duration] || 7
      self.engagement_duration = params[:engagement_duration] || 7
      self.retention_duration = params[:retention_duration] || 30
      self.churn_duration = params[:churn_duration] || 30
      validate_attributes!
    end

    def acquisition
      @acquisition ||= calculate_acquisition
    end

    def activation
      @activation ||= calculate_activation
    end

    def engagement
      @engagement ||= calculate_engagement
    end

    def retention
      @retention || calculate_retention
    end

    def churn
      @churn || calculate_churn
    end

    private

    def calculate_acquisition
      growth_metric = Totalizer::Metric.new self.growth_metric.attributes.merge(date: date, duration: acquisition_duration)
      AcqusitionMessage.new(growth_metric, acquisition_duration)
    end

    def calculate_activation
      growth_metric = Totalizer::Metric.new self.growth_metric.attributes.merge(date: date, duration: activation_duration)
      activity_metric = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date, duration: activation_duration)
      step = Totalizer::Step.new growth_metric.ids, activity_metric.ids
      ActivationMessage.new(step, activation_duration)
    end

    def calculate_engagement
      growth_metric = Totalizer::Metric.new self.growth_metric.attributes.merge(date: date, duration: engagement_duration)
      activity_metric = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date, duration: engagement_duration)
      EngagementMessage.new(growth_metric, activity_metric, engagement_duration)
    end

    def calculate_retention
      previous_period = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date - retention_duration.days, duration: retention_duration)
      this_period = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date, duration: retention_duration)
      step = Totalizer::Step.new previous_period.ids, this_period.ids
      RetentionMessage.new(step, retention_duration)
    end

    def calculate_churn
      growth_metric = Totalizer::Metric.new self.growth_metric.attributes.merge(date: date, duration: churn_duration)
      previous_activity_metric = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date - churn_duration.days, duration: churn_duration)
      this_activity_metc = Totalizer::Metric.new self.activity_metric.attributes.merge(date: date, duration: churn_duration)
      ChurnMessage.new(growth_metric, previous_activity_metric, this_activity_metc, churn_duration)
    end

    def validate_attributes!
      raise Errors::InvalidData unless growth_metric.kind_of?(Totalizer::Metric)
      raise Errors::InvalidData unless activity_metric.kind_of?(Totalizer::Metric)
      raise Errors::InvalidDate unless date.kind_of?(DateTime)
      raise Errors::InvalidDuration unless acquisition_duration.kind_of?(Integer)
      raise Errors::InvalidDuration unless activation_duration.kind_of?(Integer)
      raise Errors::InvalidDuration unless retention_duration.kind_of?(Integer)
      raise Errors::InvalidDuration unless churn_duration.kind_of?(Integer)
    end
  end
end
