# Totalizer - Calculate important metrics in your Rails application.

Provides tools to Ruby on Rails developers to create calculations for acquisition, activation, engagement, retention and churn.

## Installation

Add this line to your application's Gemfile:

    gem 'totalizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install totalizer

*** 

## Hosted Version

I've had a number of requests for a hosted version. If this is something you're interested in please sign up to be notified at [http://totalizer.io](http://totalizer.io "Totalizer")

## Metric

A Metric is a calculation based on one of your models for a duration of time. To create a Metric just use this in your Rails application:

```ruby
Totalizer::Metric.new({ title: 'New Users', model: User })
```

This will return a Metric object with the following properties:

```ruby
{ title: 'New Users', value: 10, previous_value: 5, change: 5, change_label: "+5" }
```

#### Options

You can pass the following options into the Metric:
+ `title`: A string used to identify the Metric.
+ `model` (required): The Rails model class that Totalizer will query.
+ `start_date`: When to start measuring your records. Default is `Date.today.beginning_of_day`.
+ `duration`: Duration (in days) to measure your records. Default is `7`. Must be an integer.
+ `filter`: Write a custom query to filter to determine which records to use in
  calculation. For example to find all users who created a public response you could
pass in: `filter: "is_public = true"`.
+ `map`: Default is `id`. Decide which field to map unique records on. For
  example, to find unique users who did a response you could pass in: `map:
'user_id'`.

## Funnel

A Funnel allows you to compare records from multiple metrics and returns a series of steps. To create a Funnel just use this in your Rails application:

```ruby
first_step_metric = Totalizer::Metric.new({ model: User })
second_step_metric = Totalizer::Metric.new({ model: User, filter: "actions > 0" })
Totalizer::Funnel.new title: 'Activation Funnel', metrics: [first_step_metric, second_step_metric]
```

This will return an array of Step objects with the following properties:

```ruby
[{ title: 'Signed up', value: 10, change: 0, change_label: "100%" }, { title: 'Activated', value: 5, change: 0.50, change_label: "50%" }]
```

#### Options

You can pass the following options into the Funnel:
+ `title`: A string used to identify the Funnel.
+ `metrics`: An array of Metric objects to compare.

## Step

A Step object is the result of comparing two Metric objects in a  Funnel calculation. You do not need to create your own Step objects but you will interact with them.

A Step object will have the following properties:
+ `title`: A string used to identify the Metric used for the Step calculation.
+ `value`: The number of Metric records.
+ `change`: The change in Metric records from previous step.
+ `change_label`: The change as a percentage String.

## Factory

The Totalizer Factory makes it easy to create a summary of your metrics.

To create a Factory just use this in your Rails application:

```ruby
Totalizer::Factory.new
```

#### Options

You can pass the following options into the Factory:
+ `durations`: An array for the durations to create metrics for. Default is `[7, 30]`.
+ `start_date`: When to start measuring your records. Default is `Date.today.beginning_of_day`.

### Counter

The Counter Factory will create a Metric for each duration in your Factory from your Factory start date.

To build a Counter Factory just use this in your Rails application:

```ruby
@factory = Totalizer::Factory.new
@metrics = @factory.build :counter, model: User
```

This will return an array of Metric objects with the following properties:

```ruby
[{ title: 'Last 7 days', value: 10, previous_value: 5, change: 5, change_label: "+5" }, { title: 'Last 30 days', value: 100, previous_value: 110, change: -10, change_label: "-10" }]
```

When you build a counter Factory you can pass all the same options you would use when you create a metric.

### Funnel

The Funnel Factory will create Funnels for each duration in your Factory from your Factory start date.

To build a Funnel Factory just use this in your rails application:

```ruby
@factory = Totalizer::Factory.new
@funnels = @factory.build :funnel, steps: [{ title: 'Signed up', model: User }, { title: 'Posted', model: Post, map: 'user_id' }]
```

This will return an array of Step objects with the following properties:

```ruby
[{ title: 'Last 7 days', steps: [{ title: 'Signed up', value: 10, change: 0, change_label: "100%" }, { title: 'Activated', value: 5, change: 0.50, change_label: "50%" }]}, { title: 'Last 30 days', steps: [{ title: 'Signed up', value: 60, change: 0, change_label: "100%" }, { title: 'Activated', value: 36, change: 0.60, change_label: "60%" }]}]
```

## Contributing

1. Fork it ( https://github.com/micdijkstra/totalizer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Licence

The MIT License (MIT)

Copyright (c) 2014 Michael Dijkstra

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
