module Totalizer
  class Message
    attr_accessor :title, :pretext, :text, :duration

    def days_string
      "#{duration if duration != 1} #{'day'.pluralize(duration)}"
    end
  end

  class AcqusitionMessage < Message
    def initialize growth_metric, duration
      self.duration = duration
      self.title = 'Acqusition'
      self.pretext = "Signed up in the last #{days_string}"
      self.text = "#{growth_metric.value} (Growth rate: #{(growth_metric.rate * 100).round(0)}%)"
    end
  end

  class StepMessage < Message
    def initialize step, duration
      self.duration = duration
      self.text = "#{step.finish}/#{step.start} (Conversion rate: #{(step.rate * 100).round(0)}%)"
    end
  end

  class EngagementMessage < Message
    def initialize growth_metric, activity_metric, duration
      self.duration = duration
      self.title = 'Engagement'

      existing_active = (growth_metric.start_ids & activity_metric.ids).size

      self.pretext = "Signed up more than #{days_string} ago and did key activity in the last #{days_string}"
      self.text = "#{existing_active}/#{growth_metric.start} (Engagement rate: #{(existing_active.to_f / growth_metric.start.to_f * 100).round(0)}%)"
    end
  end

  class ActivationMessage < StepMessage
    def initialize step, duration
      super
      self.title = 'Activation'
      self.pretext = "Signed up in the last #{days_string} and did key activity"
    end
  end

  class RetentionMessage < StepMessage
    def initialize step, duration
      super
      self.title = 'Retention'
      self.pretext = "Did key activity more than #{days_string} ago and again in the last #{days_string}"
    end
  end

  class ChurnMessage < Message
    def initialize growth_metric, previous_activity_metric, this_activity_metc, duration
      self.duration = duration
      self.title = 'Churn'
      self.pretext = "Acquired more than #{days_string} ago and did not do key activity in last #{days_string} over total acquired"

      new_and_existing = growth_metric.finish
      lost_existing = (previous_activity_metric.ids - this_activity_metc.ids).size
      final = new_and_existing - lost_existing

      self.text = "#{lost_existing}/#{new_and_existing} (Churn rate: #{(lost_existing.to_f / new_and_existing.to_f * 100).round(0)}%)"
    end
  end
end
