require 'net/http'
require 'cgi'

class MainController < ApplicationController  
  def bounce
    redirect_to params[:to], :status => 301
  end
  
  def index
	  filter_conditions = "nudity = false"

    @pages = Page.where('adult = false').order('updated_at desc').limit(10)
	  @latest = Game.where(filter_conditions).select('games.id, games.title, games.created_at, games.icon_file_name').order('created_at DESC').limit(4)
    @featured_games = Game.where("featured = true", :include => [:user]).order('random()').limit(6)
    @recently_popular = Game.where(["games.created_at > ?", 3.months.ago.to_s(:db)]).order('views desc').limit(4)                      
    @article = Article.first
    @pulse  = Pulse.latest_unique(:limit => 10)

    # TLA
    get_tla
  end
  
  def pulse
    @pulse  = Pulse.latest_unique(:limit => 30)
  end
  
  def load_chat
  	@user = User.find(params[:id])
  	@tag = params[:tag]
  	
  	render :partial => 'chat'
  end
  
  def search
    @query = params[:query].gsub(/[^A-Za-z0-9: ]/, '')
    unless @query.blank?
      @games = Game.basic_search(:title => @query).limit(30)
      @users = User.basic_search(:login => @query).limit(30)
    end
  end
  
  def send_contact_form
  	if request.post?
      Mailer::deliver_message(params[:author])
      redirect_to :action => 'contact'
      flash[:notice] = "Thanks for your message!"
    end
  end
  
  private

  def get_tla
    url = 'http://www.text-link-ads.com/xml.php?k=05Y7GUPVQNMO84SRDAPS&l=rails-tla-2.0.1&f=json'

    # is it time to update the cache?
    time = read_fragment('tla_time')
    if time.nil? || time < Time.now.to_s
      @links = requester(url) rescue nil

      unless @links.nil?
        expire_fragment('tla')
        expire_fragment('tla_time')
        write_fragment('tla_time', (Time.now + 6.hours).to_s)
      end
    end
  end
  
  def requester(url)
    ActiveSupport::JSON.decode(http_get(url))
  end

  def http_get(url)
    Net::HTTP.get_response(URI.parse(url)).body.to_s
  end

  def fragment_key(name)
    return "TLA/T/#{name}", "TLA/D/#{name}"
  end
end