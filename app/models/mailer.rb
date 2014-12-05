class Mailer < ActionMailer::Base
  def message(author)
    @recipients       = "natew@me.com"
    @from             = author[:email]
    @subject          = "GameGum Message"
    @body['name']     = author[:name]
    @body['email']    = author[:email]
    @body['message']  = author[:message]
  end
end 