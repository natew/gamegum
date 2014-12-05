class Topic < ActiveRecord::Base
  has_many :discussions, :dependent => :destroy
  
  validates_presence_of :title
  validates_length_of :title, :within => 1..255
  
  def to_param
    "#{title.parameterize}"
  end
  
  def to_label
    title
  end
  
end
