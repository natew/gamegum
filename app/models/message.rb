class Message < ActiveRecord::Base

  attr_accessor :recipient

  default_scope :order => 'created_at DESC'

  belongs_to :sender,
             :class_name => "User",
             :foreign_key => "sender_id"
  belongs_to :receiver,
             :class_name => "User",
             :foreign_key => "receiver_id"

  before_validation :find_receiver_from_recipient

  validates	:subject,
  			:presence => true
  validates	:body,
  			:length => { :minimum => 25, :maximum => 2000 }

  attr_accessible :read_at, :subject, :body, :recipient, :sender


  # Returns user.login for the sender
  def sender_name
    begin
      User.find(sender_id).login
    rescue Exception
      ''
    end
  end

  # Returns user.login for the receiver
  def receiver_name
    User.find(receiver_id).login || ""
  end

  def mark_message_read(user)
    if user.id == self.receiver_id
      self.read_at = Time.now
      self.save
    end
  end

  # Performs a hard delete of a message.  Should only be called from destroy
  def purge
    if self.sender_purged && self.receiver_purged
      self.destroy
    end
  end

  # Assigns the recipient to the receiver_id.
  def find_receiver_from_recipient
    begin
      u = User.find_by_login(recipient)
      self.receiver_id = u.id unless u.nil?
    rescue
    end
  end
end