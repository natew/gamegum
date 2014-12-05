namespace :import do
  task :setup => :environment do
    @num = 0
    @reset = true if (ENV["RESET"] == 'true' or ENV["R"] == 't')
    @db ||= (ENV["DB"] || 'development')
  
    if  @sql.nil?
      ActiveRecord::Base.establish_connection @db
      @sql = ActiveRecord::Base.connection
  
      require 'crack'
      require 'open-uri'
    end
  end
  
  task :kongregate => :setup do
    url  = "http://www.kongregate.com/games_for_your_site.xml"
    feed = open(url).read
    
    columns = [ :id, :title, :icon_file_name, :icon_content_type, :icon_file_size, :flash_file_name, :flash_content_type, :flash_file_size, :description, :user_id, :category_id, :width, :height, :created_at, :updated_at ]
    values = []
    
    Crack::XML.parse(feed).each do |game|
      
      created_at = Time.at(published)
      updated_at = Time.at(changed)

      # Import Icon
      if File.exists?(path_to) and !icon.empty?              
        begin
          Icon.create :game_id => id, :temp_path => path_to, :filename => icon
        rescue
          puts "error saving icon #{path_to}"
        end
      end
      
      # Import Flash
      if File.exists?(path_to) and !systemfile.empty?
        Flash.create :game_id => id, :temp_path => path_to, :filename => systemfile
      end
      
      Game.import(columns, values, :validate => false, :timestamps => false) unless values.empty?
    end
  end
end