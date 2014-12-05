class InstantMessage < ActiveRecord::Base
  belongs_to :chat
  belongs_to :user
  
  validates_length_of :message, :in => 1..1000
end
