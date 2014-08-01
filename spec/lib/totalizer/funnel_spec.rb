require 'spec_helper'

describe Totalizer::Funnel do
  describe "Validate" do
    it "requires metrics" do
      expect{ Totalizer::Funnel.new({ metrics: nil }) }.to raise_exception
    end
  end

  describe "Steps" do
    before do
      FactoryGirl.create :user, created_at: 2.days.ago
      user_2 = FactoryGirl.create :user, created_at: 4.days.ago
      user_3 = FactoryGirl.create :user, created_at: 8.days.ago
      FactoryGirl.create :post, user_id: user_2.id, created_at: 4.days.ago
      FactoryGirl.create :post, user_id: user_3.id, created_at: 8.days.ago

      first_step_metric = Totalizer::Metric.new({ model: User })
      second_step_metric = Totalizer::Metric.new({ model: Post, map: 'user_id' })

      @funnel = Totalizer::Funnel.new title: 'Activation Funnel', metrics: [first_step_metric, second_step_metric]
    end

    it "creates a step for each metric" do
      expect(@funnel.steps.size).to eq 2
    end

    it "counts the number for first step value" do
      expect(@funnel.steps.first.value).to eq 2
    end

    it "counts the number still present for second step value" do
      expect(@funnel.steps.last.value).to eq 1
    end

    it "calculates the change from previous step" do
      expect(@funnel.steps.last.change).to eq 0.5
    end

    it "outputs the change from previous step" do
      expect(@funnel.steps.last.change_label).to eq "50%"
    end
  end
end
