# Copyright 2006 Pascal Belloncle
# Textlinkads link display

defaults = {'key' => 'key-missings', 
            'affiliateid' => '11111',
            'packageid' => '11111',
            'title' => 'Sponsors',
            'affiliatemessage' => 'Monetize your blog',
            'advertisehere' => 'Advertise here!',
            'testing' => true,
            'caching' => false}
begin
  TLA_CONFIG = defaults.merge(YAML.load(ERB.new(IO.read("#{Rails.root}/config/textlinkads.yml")).result))
rescue
  TLA_CONFIG = defaults
end


require 'net/http'
require 'cgi'

module Textlinkads

  def fragment_key(name)
    return "TLA/TIME/#{name}", "TLA/DATA/#{name}", "TLA/RSS/#{name}"
  end

  def getLinks(url)
    XmlSimple.xml_in(Net::HTTP.get_response(URI.parse(url)).body.to_s)
  end

  def links_TLA()
    # check first level of caching (in memory)
    if @links && Time.now < @next_refresh
      return @links, @rss_links
    end
    @next_refresh = Time.now + 1.hour
    begin
      url = "http://www.text-link-ads.com/xml.php?inventory_key="+TLA_CONFIG['key']
      url_cache = url
      url += "&referer="+CGI::escape(@request.env['REQUEST_URI'])
      url += "&user_agent="+CGI::escape(@request.env['HTTP_USER_AGENT'])
      url += "rss_access=true" if true #TODO: add RSS flag to config
      if (TLA_CONFIG['testing'] == true)
        url = "http://www.text-link-ads.com/xml_example.xml" #this URL does not contain any RSS
      end
      if (TLA_CONFIG['caching'] == true)
        url_time, url_data, url_rss = fragment_key(url_cache)
        #is it time to update the cache?
        time = read_fragment(url_time)
        if (time == nil) || (time.to_time(:local) < Time.now)
          links = getLinks(url) rescue nil
          #if we can get the latest, then update the cache
          if (links != nil)
            filter_links(links)
            expire_fragment(url_time)
            expire_fragment(url_data)
            expire_fragment(url_rss)
            write_fragment(url_time, Time.now+6.hour)
            write_fragment(url_data, @links.to_yaml)
            write_fragment(url_rss, @rss_links.to_yaml)
            return links
          else
            #otherwise try again in 1 hour
            write_fragment(url_time, Time.now+1.hour)
            @links = YAML.load(read_fragment(url_data))
            @rss_links = YAML.load(read_fragment(url_rss))
            return @links, @rss_links
          end
        else
          #use the cache
          @links = YAML.load(read_fragment(url_data))
          @rss_links = YAML.load(read_fragment(url_rss))
          return @links, @rss_links
        end
      else
        filter_links(getLinks(url))
        return @links, @rss_links
      end
    rescue
      return nil, nil;
    end
  end
  
  def render_TLA()
    html = "<div id=\"textlinkads\"><h3>#{TLA_CONFIG['title']}</h3><ul>"
    links_TLA()
    if @links != nil
  	  for link in @links
        html += "<li>#{link['BeforeText'][0]} <a href=\"#{link['URL'][0]}\">#{link['Text'][0]}</a> #{link['AfterText'][0]}</li>"
      end
    end
    if (TLA_CONFIG['affiliateid'] != 0)
      html += "<li><a href=\"http://www.text-link-ads.com/?ref=#{TLA_CONFIG['affiliateid']}\">#{TLA_CONFIG['affiliatemessage']}</a></li>"
    end
    if (TLA_CONFIG['packageid'] != 0)
      html += "</ul><br/><a href=\"http://www.text-link-ads.com/packageDetail.php?packageID=#{TLA_CONFIG['packageid']}\">#{TLA_CONFIG['advertisehere']}</a>"
    else
      html += "</ul><br/><a href=\"http://www.text-link-ads.com/\">#{TLA_CONFIG['advertisehere']}</a>"
    end
    html += "</div>"
    return html
  end

  def render_TLA_RSS(post_id)
    tla_rss = TextLinkAdsRss.find(:first, :conditions => ['post_id = ?', post_id])
    return tla_rss.html if tla_rss

    links_TLA()
    
    link = (@rss_links) ? @rss_links[post_id % @rss_links.size] : nil
    if link
      html = "<p><strong><em>#{link['RssPrefix'][0]}</em></strong>: #{link['RssBeforeText'][0]} <a href=\"#{link['URL'][0]}\">#{link['RssText'][0]}</a><em> </em>#{link['RssAfterText'][0]}<br /></p>"
    else
      html = ""
    end

    if html != ""
      tla_rss = TextLinkAdsRss.new(:post_id => post_id, :html => html)
      tla_rss.save!
    end

    return html
  end
  
  protected
  def filter_links(links)
    @links, @rss_links = Array.new, Array.new
    count, rss_count = 0, 0
    if (links != nil) && (links["Link"] != nil)
  	  for link in links["Link"]
        if (link['RssPrefix'][0]!={}) && ((link['RssBeforeText'][0]!={}) || (link['RssText'][0]!={}) || (link['RssAfterText'][0]!={}))
          @rss_links[rss_count]= link
          rss_count += 1
        elsif ((link['BeforeText'][0]!={}) || (link['Text'][0]!={}) || (link['AfterText'][0]!={})) #regular link
          @links[count]= link
          count += 1
        end
      end
    end
  end

end

module TextlinkadsHelper
  # Render Text Link Ads links
  #   <%= render_TLA %>
  def render_TLA
    @controller.render_TLA
  end

  def render_TLA_RSS(post_id)
    @controller.render_TLA_RSS(post_id)
  end

  def links_TLA
    @controller.links_TLA
  end

end
