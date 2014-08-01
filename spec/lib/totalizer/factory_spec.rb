require 'spec_helper'

describe Totalizer::Factory do
  describe "Build" do
    before do
      user_1 = FactoryGirl.create :user, created_at: 2.days.ago
      FactoryGirl.create :post, created_at: 2.days.ago, user_id: user_1.id
      FactoryGirl.create :user, created_at: 4.days.ago
      user_2 = FactoryGirl.create :user, created_at: 8.days.ago
      FactoryGirl.create :post, created_at: 8.days.ago, user_id: user_2.id
      FactoryGirl.create :user, created_at: 16.days.ago
      user_3 = FactoryGirl.create :user, created_at: 32.days.ago
      FactoryGirl.create :post, created_at: 32.days.ago, user_id: user_3.id
      FactoryGirl.create :user, created_at: 45.days.ago
    end

    describe "Counter" do
      describe "Default" do
        before do
          @factory = Totalizer::Factory.new
          @metrics = @factory.build :counter, model: User
        end

        it "creates metrics for last 7 days" do
          expect(@metrics.first.title).to eq "Last 7 days"
        end

        it "calculates value for last 7 days" do
          expect(@metrics.first.value).to eq 2
        end

        it "calculates value for previous 7 day period" do
          expect(@metrics.first.previous_value).to eq 1
        end

        it "creates metrics for last 30 days" do
          expect(@metrics.second.title).to eq "Last 30 days"
        end

        it "calculates value for last 30 days" do
          expect(@metrics.second.value).to eq 4
        end

        it "calculates value for previous 30 day period" do
          expect(@metrics.second.previous_value).to eq 2
        end
      end

      describe "Custom" do
        before do
          @factory = Totalizer::Factory.new durations: [1], start_date: 1.day.ago.beginning_of_day
          @metrics = @factory.build :counter, model: User
        end

        it "creates one metric" do
          expect(@metrics.size).to eq 1
        end

        it "creates a metric for last 1 day" do
          expect(@metrics.first.title).to eq "Last 1 day"
        end

        it "calculates value for last 1 day" do
          expect(@metrics.first.value).to eq 1
        end

        it "calculates value for previous 1 day period" do
          expect(@metrics.first.previous_value).to eq 0
        end
      end
    end

    describe "Funnel" do
      describe "Default" do
        before do
          @factory = Totalizer::Factory.new
          @funnels = @factory.build :funnel, steps: [{ title: 'Signed up', model: User }, { title: 'Posted', model: Post, map: 'user_id' }]
        end

        it "creates steps for last 7 days" do
          expect(@funnels.first.title).to eq "Last 7 days"
        end

        it "counts the number for the first step for last 7 days" do
          expect(@funnels.first.steps.first.value).to eq 2
        end

        it "counts the number still present for first step value for previous 7 day period" do
          expect(@funnels.first.steps.first.change).to eq nil
        end

        it "counts the number for the second step for last 7 days" do
          expect(@funnels.first.steps.second.value).to eq 1
        end

        it "counts the number still present for first step value for previous 7 day period" do
          expect(@funnels.first.steps.second.change).to eq 0.5
        end

        it "creates metrics for last 30 days" do
          expect(@funnels.second.title).to eq "Last 30 days"
        end

        it "counts the number for the first step for last 30 days" do
          expect(@funnels.second.steps.first.value).to eq 4
        end

        it "counts the number still present for first step value for previous 30 day period" do
          expect(@funnels.second.steps.first.change).to eq nil
        end

        it "counts the number for the second step for last 30 days" do
          expect(@funnels.second.steps.second.value).to eq 2
        end

        it "counts the number still present for first step value for previous 30 day period" do
          expect(@funnels.second.steps.second.change).to eq 0.5
        end
      end
    end
  end
end
