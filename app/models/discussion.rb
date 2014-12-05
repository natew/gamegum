class Discussion < ActiveRecord::Base
  default_scope :order => 'discussions.created_at DESC'

  belongs_to :topic
  belongs_to :user
  has_many :posts, :dependent => :destroy
  
  validates_presence_of :user, :topic_id
  validates_length_of :title, :within => 8..255
  validates_length_of :message, :within => 30..5000
  
  before_validation(:on => :create) do
    validate_user_active
    validate_user_time_between_creating
  end
  
  def to_param
    "#{id}%2F#{title.parameterize}"
  end
  
  def to_label
    title
  end
  
  private
  
  def validate_user_time_between_creating
    if !self.user.discussions.last.nil? and (Time.now - self.user.discussions.last.created_at) < 240
      errors.add_to_base "Please wait 4 minutes between posting threads"
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
