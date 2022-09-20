class ApplicationMailer < ActionMailer::Base
  default from: ENV['EMAIL_USERNAME'] || 'test@gmail.com'
  layout 'mailer'
end
