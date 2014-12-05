class Page < ActiveRecord::Base
  has_and_belongs_to_many :games, :join_table => :pages_games
  
  has_attached_file	:image,
  					:styles => {
  						:original => {
  							:geometry 	=> '128x128#'
  						}
  					},
  					:storage        => 's3',
  					:s3_credentials => 'config/amazon_s3.yml',
                  	:path           => ':id_image.:extension',
                  	:bucket         => 'gamegum-pages'
                  	
  before_save  :create_slug

  attr_accessible :title, :description, :adult
  
  def to_param
    "#{slug}"
  end
  
  def create_slug
    self.slug = self.title.parameterize
  end
  
  def to_label
    title
  end
  
end
