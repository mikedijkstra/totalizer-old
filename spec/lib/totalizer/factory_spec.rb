require 'spec_helper'

describe Totalizer::Factory do
  describe "Build" do
    describe "counter" do
      before do
        FactoryGirl.create :user, created_at: 2.days.ago
        FactoryGirl.create :user, created_at: 4.days.ago
        FactoryGirl.create :user, created_at: 8.days.ago
        FactoryGirl.create :user, created_at: 16.days.ago
        FactoryGirl.create :user, created_at: 32.days.ago
      end

      describe "default" do
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
          expect(@metrics.second.previous_value).to eq 1
        end
      end

      describe "custom" do
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
  end
end
