module Totalizer
  extend self
  NOTIFIERS = { log: 'Totalizer::LogNotifier', action_mailer: 'Totalizer::ActionMailerNotifier', mandrill_mailer: 'Totalizer::MandrillMailerNotifier', slack: 'Totalizer::SlackNotifier' }
  attr_reader :growth_metric, :activity_metric

  def descriptions
    @descriptions ||= OpenStruct.new acquisition: "Signed up this period (with rate of change)",
      vanity: "Total this period (with rate of change)",
      activity: "Did key activity this period (with rate of change)",
      activation: "Created this period and did key activity",
      engagement: "Created before this period and did key activity this period",
      retention: "Did key activity the previous period and again this period",
      churn: "Did key activity last period but not this period over the total who did key activity last period plus new users"
  end

  def growth_metric= metric
    @growth_metric = validate_metric(metric)
  end

  def activity_metric= metric
    @activity_metric = validate_metric(metric)
  end

  def validate_metric metric
    raise Errors::InvalidMetric unless metric.kind_of?(Totalizer::Metric)
    metric
  end

  def factory
    @factory ||= Totalizer::Factory.new growth_metric, activity_metric
  end

  def date= date
    factory.date = date
  end

  def generate build, duration=nil
    factory.duration = duration
    factory.send(build)
  end

  def notifiers
    @notifiers ||= {}
  end

  def notifiers= notifiers
    @notifiers = notifiers
  end

  def notify message_groups
    notifiers.merge({ log: {} }).each { |notifier| fire_notification(notifier, message_groups) }
  end

  def fire_notification notifier_options, message_groups
    notifier = NOTIFIERS[notifier_options.first].constantize
    notifier.call(message_groups, notifier_options.last)
  end

  def weekly_day
    @weekly_day ||= 1
  end

  def weekly_day= day
    @weekly_day = day
  end
end
