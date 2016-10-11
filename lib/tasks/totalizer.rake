namespace :totalizer do
  task validate: :environment do
    abort '! Growth metric not defined. Please define your growth metric before running this task. See https://github.com/micdijkstra/totalizer' unless Totalizer.growth_metric
    abort '! Activity metric not defined. Please define your growth metric before running this task. See https://github.com/micdijkstra/totalizer' unless Totalizer.activity_metric
    abort '! Vanity metric not defined. Please define your vanity metric before running this task. See https://github.com/micdijkstra/totalizer' unless Totalizer.vanity_metric
  end

  task daily: :validate do
    Totalizer.logger.info "Totalizer: Daily"
    messages = {
      acquisition: [Totalizer.generate(:acquisition, 1)],
      vanity: [Totalizer.generate(:vanity, 1)],
      activity: [Totalizer.generate(:activity, 1)],
    }
    Totalizer.notify messages
  end

  task weekly: :validate do
    Totalizer.logger.info "Totalizer: Weekly"
    messages = {
      acquisition: [Totalizer.generate(:acquisition, 7), Totalizer.generate(:acquisition, 30)],
      vanity: [Totalizer.generate(:vanity, 7), Totalizer.generate(:vanity, 30)],
      activity: [Totalizer.generate(:activity, 7), Totalizer.generate(:activity, 30)],
      activation: [Totalizer.generate(:activation, 7), Totalizer.generate(:activation, 30)],
      engagement: [Totalizer.generate(:engagement, 7), Totalizer.generate(:engagement, 30)],
      retention: [Totalizer.generate(:retention, 7), Totalizer.generate(:retention, 30)],
      churn: [Totalizer.generate(:churn, 7), Totalizer.generate(:churn, 30)],
    }
    Totalizer.notify messages
  end

  task combined: :validate do
    if DateTime.now.wday == Totalizer.weekly_day
      Rake::Task["totalizer:weekly"].invoke
    else
      Rake::Task["totalizer:daily"].invoke
    end
  end
end
