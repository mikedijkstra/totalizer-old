require 'spec_helper'

describe Totalizer::Metric do
  describe "Validate" do
    it "requires a model" do
      expect{ Totalizer::Metric.new({ model: nil }) }.to raise_exception
    end

    it "requires a valid filter" do
      expect{ Totalizer::Metric.new({ model: User, start_date: Date.today, duration: 7, filter: 'non_existant_field = true' }) }.to raise_exception
    end
  end

  describe "Calculate" do
    before do
      FactoryGirl.create :user, created_at: 3.days.ago
      FactoryGirl.create :user, created_at: 2.days.ago
      FactoryGirl.create :user, created_at: 8.days.ago
      @metric = Totalizer::Metric.new({ model: User, start_date: Date.today })
    end

    it "counts the ids for value" do
      expect(@metric.value).to eq 2
    end

    it "counts the previous ids for value" do
      expect(@metric.previous_value).to eq 1
    end

    it "calculates the change" do
      expect(@metric.change).to eq 1
    end

    it "outputs the change" do
      expect(@metric.change_label).to eq "+1"
    end
  end

  describe "Filter" do
    before do
      FactoryGirl.create :user, created_at: 3.days.ago, actions: 2
      FactoryGirl.create :user, created_at: 2.days.ago, actions: 0
      FactoryGirl.create :user, created_at: 8.days.ago, actions: 2
      @metric = Totalizer::Metric.new({ model: User, start_date: Date.today, filter: "actions > 0" })
    end

    it "counts the ids for value" do
      expect(@metric.value).to eq 1
    end

    it "counts the previous ids for value" do
      expect(@metric.previous_value).to eq 1
    end

    it "calculates the change" do
      expect(@metric.change).to eq 0
    end

    it "outputs the change" do
      expect(@metric.change_label).to eq "0"
    end
  end
end
