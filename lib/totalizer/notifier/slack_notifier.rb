require 'slack-notifier'

module Totalizer
  class SlackNotifier < BaseNotifier
    DEFAULT_OPTIONS = { username: 'Totalizer', icon_emoji: ":nerd_face:", color: '#5767ff' }

    def self.call(message_groups, options)
      notifier = Slack::Notifier.new options[:webhook_url], DEFAULT_OPTIONS.merge(options)
      message_groups.each do |message_type, messages|
        text = messages.map{ |message| message.text }.join("\n")
        description = messages.map{ |message| message.description }.uniq.join("\n")
        notifier.ping message_type.to_s.capitalize, attachments: [{ fallback: text, color: options[:color], text: text, footer: description }]
      end
    end
  end
end
