module GamesHelper
  include ActsAsTaggableOn::TagsHelper

  def sort_td(param)
    result = 'class="sortup"' if params[:sort] == param
    result = 'class="sortdown"' if params[:sort] == param + "_reverse"
    return result
  end
  
  def sort_link(text, param)
    key = param
    key += "_reverse" if params[:sort] == param
    link_to(text, :sort => key)
  end
  
  def content_rating(bits)
    tags = [ "Nudity", "Violence", "Blood", "Language" ]
    ratings = ''
    
    rated = 'everyone'
    rated = 'mature' if (bits[2] != 0 or bits[3] != 0 or bits[4] != 0)
    rated = 'adult' if bits[1] != 0
    
    5.times do |i|
      ratings += "<li>#{tags[i-1]}</li>" if bits[i] != 0
    end
    
    render :partial => 'games/content_rating', :locals => { :ratings => ratings, :rated => rated }
  end
end
