class Article < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :title
  validates_presence_of :body
  validates_presence_of :user
  validates_length_of :body, :within => 3..10000
  validates_length_of :title, :within => 1..255
  
  default_scope :order => 'created_at DESC'
  
  def to_label
    title
  end
end
