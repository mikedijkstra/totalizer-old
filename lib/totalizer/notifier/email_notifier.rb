require 'action_mailer'

module Totalizer
  class EmailNotifier < BaseNotifier
    DEFAULT_OPTIONS = { subject: '[Totalizer] Your important metrics', from: 'totalizer@totalizer.io' }

    def self.call(message_groups, options)
      body = ""
      message_groups.each do |message_type, messages|
        body += "\n#{message_type.to_s.capitalize}\n"
        description = messages.map{ |message| message.description }.uniq.join("\n")
        body += "#{description}\n"

        text = messages.map{ |message| message.text }.join("\n")
        body += "#{text}\n"
      end

      body += "\n— Totalizer"

      self.send body, DEFAULT_OPTIONS.merge(options)
    end
  end
end
