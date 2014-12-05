require 'zlib'

class Game < ActiveRecord::Base
  # Plugins
  acts_as_rated
  acts_as_taggable

  # Associations
  belongs_to 	:category
  belongs_to 	:user
  has_many 		:comments, :include => :user, :dependent => :destroy
  has_many 		:admirers, :through => :favorites, :source => :user, :dependent => :destroy
  has_many 		:favorites, :dependent => :destroy
  has_and_belongs_to_many  :pages, :join_table => :pages_games

  # Bucket
  flash_bucket = Rails.env == 'production' ? 'gamegum-flash' : 'gamegum-flash-development'
  icon_bucket = Rails.env == 'production' ? 'gamegum-icons' : 'gamegum-icons-development'

  has_attached_file	:icon,
                    :styles => {
                      :original => {
                        :geometry 	=> '48x48#'
                      }
                    },
                  	:path           => ':id_original.:extension',
                  	:default_url    => '/assets/default.gif',
                  	:storage        => 's3',
                  	:s3_credentials => 'config/amazon_s3.yml',
                  	:bucket         => icon_bucket

  has_attached_file	:flash,
                  	:path			=> ':id_original.:extension',
                  	:storage        => 's3',
                  	:s3_credentials => 'config/amazon_s3.yml',
                  	:bucket         => flash_bucket

  # Callbacks
  after_create             :add_pulse
  after_flash_post_process :set_dimensions

  # Validations
  validates_presence_of				      :category, :message => 'must be submitted'
  validates_length_of				        :title, :within => 2..120
  validates_length_of				        :description, :within => 10..5000
  validates_attachment_presence     :flash
  validates_attachment_content_type	:flash, :content_type => 'application/x-shockwave-flash'
  validates_attachment_size			    :flash, :in => 1..15.megabytes

  attr_accessible :title, :description, :category_id, :tag_list, :violence, :langauge, :nudity, :touch_compatible, :language, :flash, :icon

  # Methods
  def rating_by(rater)
    r = ratings.find(:first, :conditions => ['rater_id = ?', rater.id])
    r.rating if !r.nil?
  end

  def self.find_within(within_days, options = {})
    conditions = [ "games.created_at > ?", within_days.days.ago.to_s(:db) ] unless within_days.zero?

    with_scope :find => { :conditions => conditions } do
      paginate options
    end
  end

  def to_param
    "#{id}/#{title.parameterize}"
  end

  def slug
    self.title.parameterize
  end

  def adult
    self.nudity
  end

  def to_label
    title
  end

  # PRIVATE
  private

  def add_pulse
    Pulse.create({:category => 'game', :description => self.description[0,180], :user => self.user, :game => self, :adult => self.nudity})
  end

  def set_dimensions
    begin
      stream = open(flash.queued_for_write[:original].path, 'rb')

      # Read the entire stream into memory because the
      # dimensions aren't stored in a standard location
      stream.rewind
      contents = stream.read

      # Our 'signature' is the first 3 bytes
      # Either FWS or CWS.  CWS indicates compression
      signature = contents[0..2]

      # Determine the length of the uncompressed stream
      length = contents[4..7].unpack('V').join.to_i

      # If we do, in fact, have compression
      if signature == 'CWS'
        # Decompress the body of the SWF
        begin
          zstream = Zlib::Inflate.new
          body = zstream.inflate( contents[8..length] )
          zstream.close
        rescue
          puts "ERROR: Could not inflate"
          return [0,0]
        end

        # And reconstruct the stream contents to the first 8 bytes (header)
        # Plus our decompressed body
        contents = contents[0..7] + body
      end

      # Determine the nbits of our dimensions rectangle
      nbits = contents[8].ord >> 3

      # Determine how many bits long this entire RECT structure is
      rectbits = 5 + nbits * 4    # 5 bits for nbits, as well as nbits * number of fields (4)

      # Determine how many bytes rectbits composes (ceil(rectbits/8))
      rectbytes = (rectbits.to_f / 8).ceil

      # Unpack the RECT structure from the stream in little-endian bit order, then join it into a string
      rect = contents[8..(8 + rectbytes)].unpack("#{'B8' * rectbytes}").join()
      contents = nil

      # Read in nbits incremenets starting from 5
      dimensions = Array.new
      4.times do |n|
        s = 5 + (n * nbits)     # Calculate our start index
        e = s + (nbits - 1)     # Calculate our end index
        dimensions[n] = rect[s..e].to_i(2)    # Read that range (binary) and convert it to an integer
      end

      # The values we have here are in "twips"
      # 20 twips to a pixel (that's why SWFs are fuzzy sometimes!)
      width   = (dimensions[1] - dimensions[0]) / 20
      height  = (dimensions[3] - dimensions[2]) / 20

      # If you can't figure this one out, you probably shouldn't have read this far
      self.width, self.height = [width, height]
    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
    end
  end
end
