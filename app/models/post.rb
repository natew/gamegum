class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion
  
  default_scope :order => 'created_at ASC'
  
  validates_presence_of :message
  validates_presence_of :user
  validates_length_of :message, :within => 4..1000
  
  before_validation(:on => :create) do
    validate_user_active
    validate_user_time_between_creating
  end
  
  def to_label
    message[0,40]
  end
  
  private
  
  def validate_user_time_between_creating
    if !self.user.posts.last.nil? and (Time.now - self.user.posts.last.created_at) < 120
      errors.add_to_base "Please wait 2 minutes between posting"
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
