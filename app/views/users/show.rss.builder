xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@cuser.login}s feed"
    xml.description "#{@cuser.login}s feed"
    xml.link user_path(@cuser)

    for pulse in @pulse
      xml.item do
        xml.title (( pulse.user.login + ' ' + ((pulse.category == 'game') ? 'submitted' : ((pulse.category == 'rating') ? 'rated' : 'commented on')) ) + ' ' + pulse.game.title)
        xml.description pulse.category == 'rating' ? stars(pulse.stars) : pulse.description
        xml.pubDate pulse.created_at.to_s(:rfc822)
        xml.link user_path(@cuser)
      end
    end
  end
end