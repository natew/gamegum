class Pulse < ActiveRecord::Base
  belongs_to :game
  belongs_to :user
  
  before_save :add_gumpoints
  before_save :crop_description
  
  default_scope :order => 'created_at DESC'

  attr_accessible :title, :description, :user, :game, :adult, :stars, :category
  
  def crop_description
    self.description = self.description[0,225] unless self.description.nil?
  end
  
  def add_gumpoints
    user = User.find(self.user_id)
    case self.category
      when 'game'
        add = 15
      when 'comment'
        add = 2
      when 'rating'
        add = 1
    end
    user.update_attribute(:gumpoints,user.gumpoints+add) if add
  end
  
  def self.latest_unique(options = {})
    self.find_by_sql("
          SELECT DISTINCT ON (foo.user_id) *
          FROM (
            SELECT   pulses.*, users.login as user_login
            FROM     pulses, users
            WHERE    adult = false
              AND pulses.user_id = users.id
            ORDER BY pulses.created_at desc
            LIMIT    #{options[:limit]*10}
          ) foo
          LIMIT #{options[:limit]}"
        )
  end
  
  def self.get(options = {})
    conditions = {}
    conditions[:category] = options[:items].nil? ? ['game', 'comment', 'rating', 'favorite'] : options.delete(:items)
    conditions[:user_id] = options.delete(:users).to_a unless options[:users].nil?
    
    with_scope :find => options do
      Pulse.find(:all, :conditions => conditions, :order => 'pulses.created_at DESC')
    end
  end
end
