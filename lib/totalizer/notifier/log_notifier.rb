module Totalizer
  class LogNotifier < BaseNotifier
    def self.call(message_groups, options)
      message_groups.each do |message_type, messages|
        Totalizer.logger.info message_type.to_s.capitalize

        description = messages.map{ |message| message.description }.uniq.join(", ")
        Totalizer.logger.info "  #{description}"

        messages.each { |message| Totalizer.logger.info "  #{message.text}" }
      end
    end
  end
end
