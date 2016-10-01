require 'spec_helper'

describe Totalizer::Factory do
  let(:growth_metric) { Totalizer::Metric.new model: User }
  let(:activity_metric) { Totalizer::Metric.new model: Post, map: 'user_id' }
  let(:duration) { nil }
  let(:date) { nil }
  let(:factory) { Totalizer::Factory.new growth_metric: growth_metric, activity_metric: activity_metric, date: date, retention_duration: 7, churn_duration: 7 }

  describe "Validate" do
    it "requires metrics" do
      expect{ Totalizer::Factory.new(growth_metric: 'fake', activity_metric: 'metric') }.to raise_exception(Totalizer::Errors::InvalidData)
    end

    it "requires activity metric" do
      expect{ Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: 'metric') }.to raise_exception(Totalizer::Errors::InvalidData)
    end

    it "requires growth metric" do
      expect{ Totalizer::Factory.new(growth_metric: 'fake', activity_metric: activity_metric) }.to raise_exception(Totalizer::Errors::InvalidData)
    end

    it "requires a valid datetime" do
      expect{ Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric, date: 'Whenever') }.to raise_exception(Totalizer::Errors::InvalidDate)
    end

    it "requires a acquisition duration" do
      expect{ Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric, acquisition_duration: 'Whatever') }.to raise_exception(Totalizer::Errors::InvalidDuration)
    end

    it "requires a activation duration" do
      expect{ Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric, activation_duration: 'Whatever') }.to raise_exception(Totalizer::Errors::InvalidDuration)
    end

    it "requires a retention duration" do
      expect{ Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric, retention_duration: 'Whatever') }.to raise_exception(Totalizer::Errors::InvalidDuration)
    end

    it "requires a churn duration" do
      expect{ Totalizer::Factory.new(growth_metric: growth_metric, activity_metric: activity_metric, churn_duration: 'Whatever') }.to raise_exception(Totalizer::Errors::InvalidDuration)
    end
  end

  describe "Initialize" do
    it "defaults to today" do
      expect(factory.date).to eq DateTime.now
    end

    it "defaults to 7 day acquisition duration" do
      expect(factory.acquisition_duration).to eq 7
    end
  end

  describe "Calculate" do
    let!(:user) { FactoryGirl.create :user, created_at: 2.days.ago }
    let(:user_2) { FactoryGirl.create :user, created_at: 4.days.ago }
    let(:user_3) { FactoryGirl.create :user, created_at: 8.days.ago }
    let(:user_4) { FactoryGirl.create :user, created_at: 10.days.ago }
    let(:user_5) { FactoryGirl.create :user, created_at: 11.days.ago }
    let(:user_6) { FactoryGirl.create :user, created_at: 12.days.ago }
    before do
      user
      FactoryGirl.create :post, user_id: user_2.id, created_at: 4.days.ago
      FactoryGirl.create :post, user_id: user_3.id, created_at: 8.days.ago
      FactoryGirl.create :post, user_id: user_4.id, created_at: 8.days.ago
      FactoryGirl.create :post, user_id: user_4.id, created_at: 2.days.ago
      FactoryGirl.create :post, user_id: user_5.id, created_at: 11.days.ago
      FactoryGirl.create :post, user_id: user_6.id, created_at: 12.days.ago
    end

    describe "Acquisition" do
      it "returns title" do
        expect(factory.acquisition.title).to eq 'Acqusition'
      end

      it "returns pretext" do
        expect(factory.acquisition.pretext).to eq 'Signed up in the last 7 days'
      end

      it "returns text" do
        expect(factory.acquisition.text).to eq "2 (Growth rate: 50%)"
      end
    end

    describe "Activation" do
      it "returns title" do
        expect(factory.activation.title).to eq 'Activation'
      end

      it "returns pretext" do
        expect(factory.activation.pretext).to eq 'Signed up in the last 7 days and did key activity'
      end

      it "returns text" do
        expect(factory.activation.text).to eq "1/2 (Conversion rate: 50%)"
      end
    end

    describe "Engagement" do
      it "returns title" do
        expect(factory.engagement.title).to eq 'Engagement'
      end

      it "returns pretext" do
        expect(factory.engagement.pretext).to eq 'Signed up more than 7 days ago and did key activity in the last 7 days'
      end

      it "returns text" do
        expect(factory.engagement.text).to eq "1/4 (Engagement rate: 25%)"
      end
    end

    describe "Retention" do
      it "returns title" do
        expect(factory.retention.title).to eq 'Retention'
      end

      it "returns pretext" do
        expect(factory.retention.pretext).to eq 'Did key activity more than 7 days ago and again in the last 7 days'
      end

      it "returns text" do
        expect(factory.retention.text).to eq "1/4 (Conversion rate: 25%)"
      end
    end

    describe "Churn" do
      it "returns title" do
        expect(factory.churn.title).to eq 'Churn'
      end

      it "returns pretext" do
        expect(factory.churn.pretext).to eq 'Acquired more than 7 days ago and did not do key activity in last 7 days over total acquired'
      end

      it "returns text" do
        expect(factory.churn.text).to eq "3/6 (Churn rate: 50%)"
      end
    end
  end
end
