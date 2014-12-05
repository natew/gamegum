class AddTextLinkAdsRssTable < ActiveRecord::Migration
  def self.up
      create_table :text_link_ads_rss do |t|
        t.column "html", :string, :limit => 1.kilobyte
        t.column "post_id", :integer
      end
  end

  def self.down
    drop_table :text_link_ads_rss
  end
end
