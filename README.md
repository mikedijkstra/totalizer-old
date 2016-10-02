# Totalizer - Calculate and share important metrics in your Rails application.

Totalizer makes it easy for Ruby on Rails developers to report on Acquisition, Activation, Activity, Engagement, Retention and Churn.

By defining two key metrics, Growth and Key Activity, all five reports can be generated.

Metrics are only worthwhile if your team sees them so Totalizer includes notifiers for Slack and email.

### Installation

Add this line to your application's Gemfile:

    gem 'totalizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install totalizer

### Configuration

You need to define your Growth Metric and Key Activity Metric in order to use Totalizer. You can do this by creating a Totalizer initializer file in your Rails application:

```ruby
# config/initializers/totalizer.rb

Totalizer.growth_metric = Totalizer::Metric.new model: User
Totalizer.activity_metric = Totalizer::Metric.new model: Post, map: 'user_id'
```

The Growth Metric and the Key Activity Metric need to map to the same id to allow comparison.

#### Metrics

A Metric is a calculation based on one of your models for a duration of time.

```ruby
metric = Totalizer::Metric.new(model: User)

metric.value
#=> 10 (the number of records for the period)

metric.start
#=> 20 (the number of records before the period)

metric.finish
#=> 30 (the number of records at the end of the period)

metric.rate
#=> 0.5 (how much the number changed over the period)
```

##### Parameters

You can pass the following parameters into the Metric:
+ `model` (required): The Rails model class that Totalizer will query.
+ `date`: When to start measuring your records. Default is `now`.
+ `duration`: Duration (in days) to measure your records from. Must be an integer. Default is `7`.
+ `filter`: Write a custom query to determine which records to use in calculation. For example to find all users who created a public response you could pass in: `filter: "is_public = true"`.
+ `map`: Which field to map records on. For example, to find unique users who did a response you could pass in: `map: 'user_id'`. Default is `id`.

#### Notifiers

By default, running the Totalizer rake tasks will output the metrics to your logs

##### Action Mailer

You can configure Totalizer to email metrics using ActionMailer, just ensure you have ActionMailer configured.

To do this add the following lines to your initializer:

```ruby
Totalizer.notifiers = {
	action_mailer: {
		from:  %{"notifier" <notifier@example.com>},
		to: %w{team@example.com}
	}
}
```

You can also optionally include: `subject`.

##### Mandrill Mailer

If you are using [mandrill_mailer gem](https://github.com/renz45/mandrill_mailer) in your application then you can configure Totalizer to email metrics using MandrillMailer, just ensure you have MandrillMailer configured.

To do this add the following lines to your initializer:

```ruby
Totalizer.notifiers = {
	mandrill_mailer: {
		from:  %{"notifier" <notifier@example.com>},
		to: %w{team@example.com}
	}
}
```

You can also optionally include: `subject`.

##### Slack Notifier

You can configure Totalizer to post to Slack by including the [slack-notifier gem](https://github.com/stevenosloan/slack-notifier) in your Gemfile.

```ruby
gem 'slack-notifier'
```

Then add the following lines to your initializer:

```ruby
Totalizer.notifiers = {
	slack: {
		webhook_url: ENV['SLACK_WEBHOOK_URL'],
		channel: ENV['SLACK_CHANNEL']
	}
}
```

You can also optionally include: `username`, `icon_emoji` and `color`.

### Usage

Totalizer comes with two rake tasks you can run.

### Daily

You don’t need to review every metric every day, but it’s good practice to monitor growth and activity on a daily basis so you can respond to any spikes or dips.

Totalizer generates your Acquisition and Activity metrics for the previous day and the previous week.

```
$ rake totalizer:daily
```

This will generate the following report:

```
Acquisition
  Yesterday: 20 (∆ 10%)
  Last 7 days: 100 (∆ 7%)
  Signed up this period (with rate of change)
Activity
  Yesterday: 60 (∆ 9%)
  Last 7 days: 120 (∆ 8%)
  Key activities this period (with rate of change)
```

### Weekly

Every week it’s important to review your important metrics to ensure you are trending in the right direction.

Totalizer generates your Activation, Engagement, Retention and Churn for the previous week and previous month.

```
$ rake totalizer:weekly
```

This will generate the following report:

```
Activation
  Created this period and did key activity
  Last 7 days: 77 → 58 (75.32%)
  Last 30 days: 444 → 355 (79.95%)
Engagement
  Created before this period and did key activity this period
  Last 7 days: 56.18% (150/267)
  Last 30 days: 34.14% (210/615)
Retention
  Did key activity the previous period and again this period
  Last 7 days: 61.19% (134/219)
  Last 30 days: 69.42% (722/1040)
Churn
  Did key activity last period but not this period over the total who did key activity last period plus new users
  Last 7 days: 6.21% (9/145)
  Last 30 days: 3.29% (34/1032)
```

### Combined

You can also run a single rake task every day which will run execute the daily
task each time and execute the weekly task on a defined week day which by
default is Monday.

This is handy for things like [Heroku Scheduler](https://elements.heroku.com/addons/scheduler)
where you can only schedule daily tasks.

```
$ rake totalizer:combined
```

To change the week day add the following line to your initializer:

```ruby
Totalizer.weekly_day = 0 #(0-6, Sunday is zero)
```

***

In addition to Metric, you can also use the following underlying objects.

### Factory

The Totalizer Factory is what generates the Acquisition, Activation, Engagement, Retention and Churn reports.

By defining one growth metric, like new user creation, and one key activity metric, like creating a post, you can generate all five reports.

To create a Factory just use this in your Rails application:

```ruby
growth_metric = Totalizer::Metric.new(model: User)
activity_metric = Totalizer::Metric.new(model: Project, map: 'user_id')
factory = Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric)
```

This will return a message object for each calculation.

##### Parameters

You can pass the following parameters into the Factory:

+ `growth_metric`: (required) a Totalizer metric representing growth, usually a User model.
+ `activity_metric`: (required) a Totalizer metric representing the key activity a user should do within your application.
+ `date`: When to start measuring your records from. Must be a DateTime. Default is `now`.
+ `duration`: Duration (in days) to measure your records. Must be an integer. Default is `7`.

#### Acquisition

```ruby
growth_metric = Totalizer::Metric.new(model: User)
activity_metric = Totalizer::Metric.new(model: Project, map: 'user_id')
factory = Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric)
acquisition = factory.acquisition

acquisition.title
#=> "Acquisition"

acquisition.pretext
#=> "Signed up in the last 7 days"

acquisition.text
#=> "74 (Growth rate: 10%)"
```

#### Activation

```ruby
growth_metric = Totalizer::Metric.new(model: User)
activity_metric = Totalizer::Metric.new(model: Project, map: 'user_id')
factory = Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric)
activation = factory.activation

activation.title
#=> "Activation"

activation.pretext
#=> "Signed up in the last 7 days and did key activity"

activation.text
#=> "63/90  (Conversion rate: 70%)"
```

#### Engagement

```ruby
growth_metric = Totalizer::Metric.new(model: User)
activity_metric = Totalizer::Metric.new(model: Project, map: 'user_id')
factory = Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric)
engagement = factory.engagement

engagement.title
#=> "Engagement"

retention.pretext
#=> "Signed up more than 7 days ago and did key activity in the last 7 days"

engagement.text
#=> "42/350 (Engagement rate: 12%)"
```

#### Retention

```ruby
growth_metric = Totalizer::Metric.new(model: User)
activity_metric = Totalizer::Metric.new(model: Project, map: 'user_id')
factory = Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric)
retention = factory.retention

retention.title
#=> "Retention"

retention.pretext
#=> "Did key activity more than 7 days ago and again in the last 7 days"

retention.text
#=> "42/75  56%"
```

#### Churn

```ruby
growth_metric = Totalizer::Metric.new(model: User)
activity_metric = Totalizer::Metric.new(model: Project, map: 'user_id')
factory = Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric)
churn = factory.churn

churn.title
#=> "Churn"

churn.pretext
#=> "Acquired more than 7 days ago and did not do key activity in last 7 days over total acquired"

churn.text
#=> "33/75  44%"
```

### Step

A step allows you to easily compare two sets of ids to see who converted.

To create a Step just use this in your Rails application:

```ruby
first_metric = Totalizer::Metric.new(model: User)
second_metric = Totalizer::Metric.new(model: Post, map: 'user_id')
step = Totalizer::Step.new first_step_metric.ids, second_step_metric.ids

step.start
#=> 20 (the number of records that started the step)

step.finish
#=> 10 (the number of records that finished the step)

step.rate
#=> 0.5 (the rate that converted from start to finish)

step.ids
#=> [1,2,3,4,5,6,7,8,9,10] (the ids of the records that finished)
```

You can use the result of one step to feed into another step. Continuing on the example above, you could do the following:

```ruby
third_metric = Totalizer::Metric.new(model: Comment, map: 'user_id')
next_step = Totalizer::Step.new step.ids, third_metric.ids
```

## Manual Calculations

You can also report on Acquisition, Activity, Activation, Retention, Engagement and Churn yourself without using a Factory.

### Acquisition

```ruby
acquisition = Totalizer::Metric.new(model: User, duration: 7)

acquisition.value
#=> 7

acquisition.rate
#=> 10
```

### Activity

```ruby
activity = Totalizer::Metric.new(model: Post, map: 'user_id')

acquisition.value
#=> 20

acquisition.rate
#=> 5
```

### Activation

```ruby
sign_up = Totalizer::Metric.new(model: User, duration: 7)
do_action = Totalizer::Metric.new(model: Post, map: 'user_id')
activation = Totalizer::Step.new sign_up.ids, do_action.ids

activation.start
#=> 10

activation.finish
#=> 5

activation.rate
#=> 0.5
```

### Engagement

```ruby
sign_up = Totalizer::Metric.new(model: User, duration: 7)
do_action = Totalizer::Metric.new(model: Post, map: 'user_id')

existing_active = (sign_up.start_ids & do_action.ids).size
#=> 14

"(existing_active.to_f / sign_up.start.to_f * 100).round(0)}%"
#=> 12%
```

### Retention

```ruby
this_week = Totalizer::Metric.new(model: Post, map: 'user_id')
last_week = Totalizer::Metric.new(model: Post, map: 'user_id')
retention = Totalizer::Step.new this_week.ids, last_week.ids

retention.start
#=> 14

retention.finish
#=> 7

retention.rate
#=> 0.5

"#{(retention.rate * 100).round(0)}%"
#=> 50%
```

### Churn

```ruby
acquisition = Totalizer::Metric.new(model: User, duration: 30)
active_last_period = Totalizer::Metric.new(model: Post, map: 'user_id', duration: 30, date: 30.days.ago)
active_this_period = Totalizer::Metric.new(model: Post, map: 'user_id', duration: 30)

new_and_existing_customers = acquisition.end_value
#=> 100

lost_existing_customers = (active_last_period.ids - active_this_period.ids).size
#=> 5

lost_existing_customers.to_f / (new_and_existing_customers - lost_existing_customers).to_f
#=> 0.04
```

## Contributing

1. Fork it ( https://github.com/micdijkstra/totalizer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Publishing

1. Update the version number in `lib/totalizer/version.rb`
2. Run `gem build totalizer.gemspec`
3. Run `gem push totalizer-0.0.X.gem`

## Licence

The MIT License (MIT)

Copyright (c) 2016 Michael Dijkstra

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
