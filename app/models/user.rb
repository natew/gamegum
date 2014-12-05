require 'digest/md5'

class User < ActiveRecord::Base
  default_scope :order => 'users.created_at DESC'

  has_many_friends
  has_many :games,       :dependent => :destroy
  has_many :comments,    :dependent => :destroy
  has_many :articles
  has_many :posts,       :dependent => :destroy
  has_many :discussions, :dependent => :destroy
  has_many :pulses,      :dependent => :destroy
  has_many :favorites,   :dependent => :destroy
  has_many :favorite_games, :through => :favorites, :source => :game

  # ---------------------------------------
  # Attachments
  has_attached_file	:avatar,
  					:styles => {
  						:original => {
  							:geometry 	=> '48x48#'
  						}
  					},
                  	:path           => ':id_:style.:extension',
                  	:default_url    => '/assets/default.gif',
                  	:storage        => 's3',
                  	:s3_credentials => 'config/amazon_s3.yml',
                  	:bucket         => 'gamegum-avatars'


  # ---------------------------------------
  # Messaging
  has_many :messages_as_sender,
                   :class_name => "Message",
                   :foreign_key => "sender_id"

  has_many :messages_as_receiver,
           :class_name => "Message",
           :foreign_key => "receiver_id"

  has_many :users_whom_i_have_messaged,
           :through => :messages_as_sender,
           :source => :receiver,
           :select => "users.*, messages.id AS message_id, messages.subject, messages.body, messages.created_at AS sent_at, messages.read_at"

  has_many :unread_messages,
           :through => :messages_as_receiver,
           :source => :sender,
           :conditions => "messages.read_at IS NULL",
           :select => "users.*, messages.id AS message_id, messages.subject, messages.body, messages.created_at AS sent_at, messages.read_at"

  has_many :read_messages,
           :through => :messages_as_receiver,
           :source => :sender,
           :conditions => "messages.read_at IS NOT NULL",
           :select => "users.*, messages.id AS message_id, messages.subject, messages.body, messages.created_at AS sent_at, messages.read_at"

  has_many :inbox_messages,
           :class_name => "Message",
           :foreign_key => "receiver_id",
           :conditions => "receiver_deleted IS NULL",
           :order => "created_at DESC"

  has_many :outbox_messages,
           :class_name => "Message",
           :foreign_key => "sender_id",
           :conditions => "sender_deleted IS NULL",
           :order => "created_at DESC"
  # ---------------------------------------


  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates                 :password,  :presence => true,
                                        :length   => { :minimum => 6, :maximum => 40 },
                                        :confirmation => true,
                                        :if => :password_required?

  validates_length_of       :login,    :within => 3..120
  validates_length_of       :email,    :within => 6..200
  validates_format_of       :email,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  before_save				:encrypt_password

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :about_me, :location, :aim, :website, :msn, :age, :avatar, :show_avatar, :adsense, :show_email

  def to_param
    "#{id.to_s}/#{slug}"
  end

  def slug
    self.login.parameterize
  end

  def is_admin?
    self.permissions.to_i >= 3
  end

  def of_age?
    return true if years_old >= 18
  end

  def years_old
    born = self.age
    return 0 if born.nil?
    now = Time.now.to_date
    now.year - born.year - ((now.month > born.month || (now.month == born.month && now.day >= born.day)) ? 0 : 1)
  end

  def to_label
    login
  end

  def show_avatar?
    self.show_avatar and !self.avatar.nil? ? true : false
  end

  def self.find_by_email_or_login(email_or_login)
    self.where("login = ?", email_or_login).limit(1).first ||
    self.where("email = ?", email_or_login).limit(1).first
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find(:first, :conditions => ["login = ? and banned = false", login]) # need to get the salt
    u and u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::MD5.hexdigest(Digest::MD5.hexdigest(password) + salt)
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(:validate => false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(:validate => false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def has_favorite?(game)
    unless self.favorites.empty?
      self.favorites.find_by_game_id(game) ? true : false
    end
  end

  def has_friend?(friend)
    unless self.friends.empty?
      self.friends.find_by_id(friend) ? true : false
    end
  end

  # Returns a list of all the users who the user has messaged
  def users_messaged
    self.users_whom_i_have_messaged
  end

  # Returns a list of all the users who have messaged the user
  def users_messaged_by
    self.users_who_messaged_me
  end

  # Returns a list of all the users who the user has mailed or been mailed by
  def all_messages
    self.users_messaged + self.users_messaged_by
  end

  # Alias for read messages
  def old_messages
    self.read_messages
  end

  # Accepts an email object and flags the email as deleted by sender
  def delete_from_sent(message)
    if message.sender_id == self.id
      message.update_attribute :sender_deleted, true
      return true
    else
      return false
    end
  end

  # Accepts an email object and flags the email as deleted by receiver
  def delete_from_received(message)
    if message.receiver_id == self.id
      message.update_attribute :receiver_deleted, true
      return true
    else
      return false
    end
  end

  # Accepts a user object as the receiver, and an email
  # and creates an email relationship joining the two users
  def send_message(receiver, message)
    Message.create!(:sender => self, :receiver => receiver, :subject => message.subject, :body => message.body)
  end

  protected

  def encrypt_password
    return if password.blank?
    self.salt = Digest::MD5.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end
end
