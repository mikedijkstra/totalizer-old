require 'spec_helper'

describe Totalizer::Step do
  let(:metric_1) { Totalizer::Metric.new(model: User) }
  let(:metric_2) { Totalizer::Metric.new(model: Post, map: 'user_id') }

  describe "Validate" do
    it "requires arrays" do
      expect{ Totalizer::Step.new('fake', 'metric') }.to raise_exception(Totalizer::Errors::InvalidData)
    end

    it "requires two arrays" do
      expect{ Totalizer::Step.new(metric_1.ids, 'metric') }.to raise_exception(Totalizer::Errors::InvalidData)
    end

    it "requires two arrays" do
      expect{ Totalizer::Step.new('fake', metric_2.ids) }.to raise_exception(Totalizer::Errors::InvalidData)
    end
  end

  describe "Calculate" do
    let(:user) { FactoryGirl.create :user, created_at: 2.days.ago }
    let(:user_2) { FactoryGirl.create :user, created_at: 4.days.ago }
    let(:user_3) { FactoryGirl.create :user, created_at: 8.days.ago }
    let(:step) { Totalizer::Step.new metric_1.ids, metric_2.ids }
    before do
      user
      FactoryGirl.create :post, user_id: user_2.id, created_at: 4.days.ago
      FactoryGirl.create :post, user_id: user_3.id, created_at: 8.days.ago
    end

    it "maps the ids who finishd the step" do
      expect(step.ids).to eq [user_2.id]
    end

    it "counts the number who start the step" do
      expect(step.start).to eq 2
    end

    it "counts the number who finishd the step" do
      expect(step.finish).to eq 1
    end

    it "calculates the rate from previous step" do
      expect(step.rate).to eq 0.5
    end
  end
end
