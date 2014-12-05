class Category < ActiveRecord::Base  
  validates_presence_of :title
  validates_uniqueness_of :title
  
  def to_param
    self.title.parameterize
  end
  
  def to_label
    title
  end
end
