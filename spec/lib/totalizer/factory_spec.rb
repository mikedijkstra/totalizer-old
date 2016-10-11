require 'spec_helper'

describe Totalizer::Factory do
  let(:growth_metric) { Totalizer::Metric.new model: User }
  let(:activity_metric) { Totalizer::Metric.new model: Post, map: 'user_id' }
  let(:vanity_metric) { Totalizer::Metric.new model: Post }
  let(:duration) { nil }
  let(:date) { nil }
  let(:factory) { Totalizer::Factory.new growth_metric, activity_metric, vanity_metric, date: date }

  describe "Validate" do
    it "requires metrics" do
      expect{ Totalizer::Factory.new('fake', 'metric', 'here') }.to raise_exception(Totalizer::Errors::InvalidMetric)
    end

    it "requires activity metric" do
      expect{ Totalizer::Factory.new(growth_metric, 'metric', vanity_metric) }.to raise_exception(Totalizer::Errors::InvalidMetric)
    end

    it "requires growth metric" do
      expect{ Totalizer::Factory.new('fake', activity_metric, vanity_metric) }.to raise_exception(Totalizer::Errors::InvalidMetric)
    end

    it "requires vanity metric" do
      expect{ Totalizer::Factory.new(growth_metric, activity_metric, 'here') }.to raise_exception(Totalizer::Errors::InvalidMetric)
    end

    it "requires a valid datetime" do
      expect{ Totalizer::Factory.new(growth_metric, activity_metric, vanity_metric, date: 'Whenever') }.to raise_exception(Totalizer::Errors::InvalidDate)
    end

    it "requires a duration" do
      expect{ Totalizer::Factory.new(growth_metric, activity_metric, vanity_metric, duration: 'Whatever') }.to raise_exception(Totalizer::Errors::InvalidDuration)
    end
  end

  describe "Initialize" do
    it "defaults to today" do
      expect(factory.date).to eq DateTime.now
    end

    it "defaults to 7 day acquisition duration" do
      expect(factory.duration).to eq 7
    end

    it "defaults description text" do
      expect(factory.vanity.description).to eq "Total this period (with rate of change)"
    end

    it "overrides description text" do
      original = Totalizer.descriptions.vanity
      Totalizer.descriptions.vanity = "Sites created"
      expect(factory.vanity.description).to eq "Sites created"
      Totalizer.descriptions.vanity = original
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
      it "returns text" do
        expect(factory.acquisition.text).to eq "Last 7 days: 2 (∆ 50% | Σ 6)"
      end
    end

    describe "Vanity" do
      it "returns text" do
        expect(factory.vanity.text).to eq "Last 7 days: 2 (∆ 50% | Σ 6)"
      end
    end

    describe "Activity" do
      it "returns text" do
        expect(factory.activity.text).to eq "Last 7 days: 2 (∆ 25% | Σ 5)"
      end
    end

    describe "Activation" do
      it "returns text" do
        expect(factory.activation.text).to eq "Last 7 days: 2 → 1 (50%)"
      end
    end

    describe "Engagement" do
      it "returns text" do
        expect(factory.engagement.text).to eq "Last 7 days: 25% (1/4)"
      end
    end

    describe "Retention" do
      it "returns text" do
        expect(factory.retention.text).to eq "Last 7 days: 25% (1/4)"
      end
    end

    describe "Churn" do
      let(:user_7) { FactoryGirl.create :user, created_at: 13.days.ago }
      before do
        FactoryGirl.create :post, user_id: user_7.id, created_at: 13.days.ago
      end

      it "returns text" do
        expect(factory.churn.text).to eq "Last 7 days: 57.14% (4/7)"
      end
    end
  end
end
