namespace :totalizer do
  task validate: :environment do
    abort '! Growth metric not defined. Please define your growth metric before running this task. See https://github.com/micdijkstra/totalizer' unless Totalizer.growth_metric
    abort '! Activity metric not defined. Please define your growth metric before running this task. See https://github.com/micdijkstra/totalizer' unless Totalizer.activity_metric
  end

  task daily: :validate do
    Totalizer.logger.info "Totalizer: Daily"
    messages = {
      acquisition: [Totalizer.generate(:acquisition, 1), Totalizer.generate(:acquisition, 7)],
      activity: [Totalizer.generate(:activity, 1), Totalizer.generate(:activity, 7)],
    }
    Totalizer.notify messages
  end

  task weekly: :validate do
    Totalizer.logger.info "Totalizer: Weekly"
    messages = {
      activation: [Totalizer.generate(:activation, 7), Totalizer.generate(:activation, 30)],
      engagement: [Totalizer.generate(:engagement, 7), Totalizer.generate(:engagement, 30)],
      retention: [Totalizer.generate(:retention, 7), Totalizer.generate(:retention, 30)],
      churn: [Totalizer.generate(:churn, 7), Totalizer.generate(:churn, 30)],
    }
    Totalizer.notify messages
  end

  task combined: :validate do
    Rake::Task["daily"].invoke
    Rake::Task["weekly"].invoke if DateTime.now.wday == Totalizer.weekly_day
  end
end
