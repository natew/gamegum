class Comment < ActiveRecord::Base
  belongs_to   :user
  belongs_to   :game
  
  after_create :create_pulse
  
  validates_presence_of  :message
  validates_presence_of  :user
  validates_length_of    :message, :within => 3..800
  
  default_scope :order => 'created_at DESC'
  
  before_validation(:on => :create) do
    validate_user_active
  	validate_user_time_between_creating
  end
  
  def to_label
    message[0,40]
  end
  
  private
  
  def create_pulse
    if errors.empty?
      Pulse.create({
        :category => 'comment',
        :description => self.message,
        :user => self.user,
        :game => self.game,
        :adult => (true unless self.game.nudity?)
      })
    end
  end
  
  def validate_user_time_between_creating
    if !self.user.comments.last.nil? and (Time.now - self.user.comments.last.created_at) < 30
      errors.add_to_base "Please wait 30 seconds between posting"
      false
    else
      true
    end
  end
  
  def validate_user_active
    unless self.user.email_confirmed
      errors.add_to_base "Account not activated!  Please click the activate link in your email.  Didn't receive any email?  Try resending it in your account pane."
      false
    else
      true
    end
  end
end
