class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    activate      = user.created_at.gsub(/[^0-9]/,'')
    body[:url]    = "http://www.gamegum.com/activate/#{user.id}/#{activate}"
  end
  
  def activation(user)
    setup_email(user)
    subject       = 'Your account has been activated!'
    body[:url]    = "http://www.gamegum.com/"
  end
  
  protected
    def setup_email(user)
      recipients  = "#{user.login} <#{user.email}>"
      from        = "activationmailer@gamegum.com"
      subject     = "Welcome to GameGum!  Please activate your new account"
      sent_on     = Time.now
      body[:user] = user
    end
end
