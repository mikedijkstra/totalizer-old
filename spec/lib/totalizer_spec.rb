require 'spec_helper'

describe Totalizer do
  describe "Validate" do
    it "require a growth metrics" do
      expect{ Totalizer.growth_metric = 'fake' }.to raise_exception(Totalizer::Errors::InvalidMetric)
    end

    it "require an activity metric" do
      expect{ Totalizer.activity_metric = 'fake' }.to raise_exception(Totalizer::Errors::InvalidMetric)
    end
  end

  describe "Initialize" do
    let(:growth_metric) { Totalizer::Metric.new model: User }
    let(:activity_metric) { Totalizer::Metric.new model: Post, map: 'user_id' }

    before do
      Totalizer.growth_metric = growth_metric
      Totalizer.activity_metric = activity_metric
    end

    it "creates a factory" do
      expect(Totalizer.factory).not_to eq nil
      expect(Totalizer.factory.kind_of?(Totalizer::Factory)).to eq true
    end
  end

  describe ".notify" do
    let(:growth_metric) { Totalizer::Metric.new model: User }
    let(:message) { Totalizer::AcqusitionMessage.new(growth_metric, 1) }
    let(:messages) { { activation: [message] } }
    before do
      allow(Totalizer::ActionMailerNotifier).to receive(:send)
      allow(Totalizer::MandrillMailerNotifier).to receive(:send)
      allow( Slack::Notifier::DefaultHTTPClient).to receive(:post)
    end

    it "does not send to Slack by default" do
      Totalizer.notify messages
      expect(Totalizer::SlackNotifier).not_to receive(:call)
    end

    describe "with action mailer notifier configured" do
      before do
        Totalizer.notifiers = {
          action_mailer: {
            to: 'admin@example.com'
          }
        }
      end

      it "sends Email" do
        Totalizer.notify messages
        expect(Totalizer::ActionMailerNotifier).to respond_to(:send).with(2).arguments
      end
    end

    describe "with mandrill mailer notifier configured" do
      before do
        Totalizer.notifiers = {
          mandrill_mailer: {
            to: 'admin@example.com'
          }
        }
      end

      it "sends Email" do
        Totalizer.notify messages
        expect(Totalizer::MandrillMailerNotifier).to respond_to(:send).with(2).arguments
      end
    end


    describe "with Slack notifier configured" do
      before do
        Totalizer.notifiers = {
          slack: {
            webhook_url: 'http://slack.webhook.url',
            channel: '#general'
          }
        }
      end

      it "sends to Slack" do
        Totalizer.notify messages
        expect(Totalizer::SlackNotifier).to respond_to(:call).with(2).arguments
      end
    end
  end
end
