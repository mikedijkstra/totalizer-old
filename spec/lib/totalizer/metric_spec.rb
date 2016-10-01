require 'spec_helper'

describe Totalizer::Metric do
  let(:metric) { Totalizer::Metric.new(model: User) }

  describe "Validate" do
    it "requires a model" do
      expect{ Totalizer::Metric.new(model: nil) }.to raise_exception(Totalizer::Errors::InvalidModel)
    end

    it "requires a valid datetime" do
      expect{ Totalizer::Metric.new(model: User, date: 'Whenever') }.to raise_exception(Totalizer::Errors::InvalidDate)
    end

    it "requires a duration" do
      expect{ Totalizer::Metric.new(model: User, duration: 'Whatever') }.to raise_exception(Totalizer::Errors::InvalidDuration)
    end
  end

  describe "Initialize" do
    it "defaults to today" do
      expect(metric.date).to eq DateTime.now
    end

    it "defaults to 7 day duration" do
      expect(metric.duration).to eq 7
    end

    it "sets the range" do
      expect(metric.start_date).to eq DateTime.now - 7.days
      expect(metric.end_date).to eq DateTime.now
    end

    it "defaults map to id" do
      expect(metric.map).to eq 'id'
    end
  end


  describe "Calculate" do
    let!(:user_1) { FactoryGirl.create :user, created_at: 8.days.ago }
    let!(:user_2) { FactoryGirl.create :user, created_at: 3.days.ago }
    let!(:user_3) { FactoryGirl.create :user, created_at: 2.days.ago }

    it "maps the ids for the duration" do
      expect(metric.ids).to eq [user_2.id, user_3.id]
    end

    it "counts the ids for duration" do
      expect(metric.value).to eq 2
    end

    it "maps the ids for the start" do
      expect(metric.start_ids).to eq [user_1.id]
    end

    it "counts the ids for start" do
      expect(metric.start).to eq 1
    end

    it "maps the ids for the end" do
      expect(metric.finish_ids).to eq [user_1.id, user_2.id, user_3.id]
    end

    it "counts the ids for end" do
      expect(metric.finish).to eq 3
    end

    it "calculates the rate of rate" do
      expect(metric.rate).to eq 2
    end

    describe 'with invalid filter' do
      let(:metric) { Totalizer::Metric.new(model: User, date: DateTime.now, duration: 7, filter: 'non_existant_field = true') }

      it "requires a valid filter" do
        expect{ metric.value }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe "Filter" do
    let!(:user_1) { FactoryGirl.create :user, created_at: 8.days.ago, actions: 2 }
    let!(:user_2) { FactoryGirl.create :user, created_at: 3.days.ago, actions: 0 }
    let!(:user_3) { FactoryGirl.create :user, created_at: 2.days.ago, actions: 2 }
    let(:metric) { Totalizer::Metric.new(model: User, filter: "actions > 0") }

    it "maps the ids for the duration" do
      expect(metric.ids).to eq [user_3.id]
    end

    it "counts the ids for duration" do
      expect(metric.value).to eq 1
    end

    it "maps the ids for the start" do
      expect(metric.start_ids).to eq [user_1.id]
    end

    it "counts the ids for start" do
      expect(metric.start).to eq 1
    end

    it "maps the ids for the end" do
      expect(metric.finish_ids).to eq [user_1.id, user_3.id]
    end

    it "counts the ids for end" do
      expect(metric.finish).to eq 2
    end

    it "calculates the rate of rate" do
      expect(metric.rate).to eq 1
    end
  end
end
