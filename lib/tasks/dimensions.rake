STDOUT.sync = true

namespace :dimensions do
  task :update => :environment do
    Game.where(:width => '0').each do |game|
      game.save
      print '.'
    end
  end
end
  