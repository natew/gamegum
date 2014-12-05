atom_feed do |feed|
  feed.title("#{@user.login}'s Games")
  feed.updated((@submissions.first.created_at))

  for game in @submissions
    feed.entry(game) do |entry|
      entry.title(game.title)
      entry.content(game.description, :type => 'html')

      entry.author do |author|
        author.name(@user.login)
      end
    end
  end
end