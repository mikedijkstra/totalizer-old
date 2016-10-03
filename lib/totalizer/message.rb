module Totalizer
  class Message
    attr_accessor :description, :text, :duration

    def period_string
      if duration > 1
        "Last #{duration} #{'day'.pluralize(duration)}"
      else
        duration == 0 ? 'Today' : 'Yesterday'
      end
    end

    def percentage_string value
      "#{(value.to_f * 100).round(2).to_s.gsub(/.0$/, '')}%"
    end
  end

  class MetricMessage < Message
    def initialize metric, duration
      self.duration = duration
      self.text = "#{period_string}: #{metric.value} (∆ #{percentage_string(metric.rate)})"
    end
  end

  class AcqusitionMessage < MetricMessage
    def initialize metric, duration
      super
      self.description = "Signed up this period (with rate of change)"
    end
  end

  class ActivityMessage < MetricMessage
    def initialize metric, duration
      super
      self.description = "Did key activity this period (with rate of change)"
    end
  end

  class ActivationMessage < Message
    def initialize step, duration
      self.duration = duration
      self.text = "#{period_string}: #{step.start} → #{step.finish} (#{percentage_string(step.rate)})"
      self.description = "Created this period and did key activity"
    end
  end

  class EngagementMessage < Message
    def initialize growth_metric, activity_metric, duration
      self.duration = duration

      existing_active = (growth_metric.start_ids & activity_metric.ids).size
      self.text = "#{period_string}: #{percentage_string existing_active.to_f / growth_metric.start.to_f} (#{existing_active}/#{growth_metric.start})"
      self.description = "Created before this period and did key activity this period"
    end
  end

  class RetentionMessage < Message
    def initialize step, duration
      self.duration = duration
      self.text = "#{period_string}: #{percentage_string(step.rate)} (#{step.finish}/#{step.start})"
      self.description = "Did key activity the previous period and again this period"
    end
  end

  class ChurnMessage < Message
    def initialize growth_metric, previous_activity_metric, this_activity_metc, duration
      self.duration = duration

      new_and_existing = previous_activity_metric.value + growth_metric.value
      lost_existing = (previous_activity_metric.ids - this_activity_metc.ids).size
      final = new_and_existing - lost_existing
      self.text = "#{period_string}: #{percentage_string lost_existing.to_f / new_and_existing.to_f} (#{lost_existing}/#{new_and_existing})"
      self.description = "Did key activity last period but not this period over the total who did key activity last period plus new users"
    end
  end
end
