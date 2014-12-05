class PagesGames < ActiveRecord::Base
  belongs_to  :game
  belongs_to  :page
end
