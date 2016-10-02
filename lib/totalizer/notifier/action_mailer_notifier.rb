module Totalizer
  class ActionMailerNotifier < EmailNotifier
    def self.send body, options
      ActionMailer::Base.mail(from: options[:from], to: options[:to], subject: options[:subject], body: body).deliver_now
    end
  end
end
