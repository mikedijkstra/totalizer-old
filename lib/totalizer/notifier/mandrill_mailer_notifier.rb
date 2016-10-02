module Totalizer
  class MandrillMailerNotifier< EmailNotifier
    def self.send body, options
      MandrillMailer::MessageMailer.mandrill_mail(from: options[:from], to: options[:to], subject: options[:subject], text: body).deliver_now
    end
  end
end
