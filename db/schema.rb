# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110501045358) do

  create_table "ads", :force => true do |t|
    t.string   "title"
    t.string   "location"
    t.text     "code"
    t.text     "alternate"
    t.date     "expires"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", :force => true do |t|
    t.string   "title",                        :null => false
    t.text     "body",                         :null => false
    t.boolean  "live",       :default => true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "awards", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string "title", :null => false
  end

  create_table "chats", :force => true do |t|
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "message",    :null => false
    t.integer  "game_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["game_id", "user_id"], :name => "index_comments_on_game_id_and_user_id"

  create_table "discussions", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "user_id"
    t.string   "title",                         :null => false
    t.text     "message",                       :null => false
    t.integer  "views",      :default => 0
    t.boolean  "locked",     :default => false
    t.boolean  "sticky",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discussions", ["topic_id", "user_id"], :name => "index_discussions_on_topic_id_and_user_id"

  create_table "favorites", :force => true do |t|
    t.integer "user_id"
    t.integer "game_id"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "friend_id",   :null => false
    t.datetime "created_at"
    t.datetime "accepted_at"
  end

  create_table "games", :force => true do |t|
    t.string   "title",                                                                     :null => false
    t.string   "screenshot"
    t.integer  "views",                                                  :default => 0,     :null => false
    t.integer  "rating_count",                                           :default => 0,     :null => false
    t.decimal  "rating_total",                                           :default => 0.0
    t.decimal  "rating_avg",              :precision => 10, :scale => 2, :default => 0.0
    t.boolean  "featured",                                               :default => false
    t.boolean  "active",                                                 :default => false
    t.boolean  "nudity",                                                 :default => false
    t.boolean  "violence",                                               :default => false
    t.boolean  "language",                                               :default => false
    t.text     "description",                                                               :null => false
    t.integer  "user_id",                                                                   :null => false
    t.integer  "category_id",                                                               :null => false
    t.datetime "featured_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.string   "flash_file_name"
    t.string   "flash_content_type"
    t.integer  "flash_file_size"
    t.integer  "width",                                                  :default => 0
    t.integer  "height",                                                 :default => 0
    t.string   "screenshot_file_name"
    t.string   "screenshot_content_type"
    t.integer  "screenshot_file_size"
    t.datetime "screenshot_updated_at"
    t.boolean  "touch_compatible",                                       :default => false
  end

  add_index "games", ["user_id", "category_id", "title"], :name => "index_games_on_user_id_and_category_id_and_title"

  create_table "instant_messages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "chat_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.boolean  "receiver_deleted"
    t.boolean  "receiver_purged"
    t.boolean  "sender_deleted"
    t.boolean  "sender_purged"
    t.datetime "read_at"
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.string   "subject",          :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["sender_id", "receiver_id"], :name => "index_messages_on_sender_id_and_receiver_id"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.string   "image_file_name"
    t.string   "image_file_size"
    t.string   "image_content_type"
    t.text     "description"
    t.integer  "views",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "adult",              :default => false, :null => false
  end

  create_table "pages_games", :id => false, :force => true do |t|
    t.integer "page_id"
    t.integer "game_id"
  end

  create_table "posts", :force => true do |t|
    t.integer  "discussion_id"
    t.integer  "user_id"
    t.text     "message"
    t.boolean  "active",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["discussion_id", "user_id"], :name => "index_posts_on_discussion_id_and_user_id"

  create_table "pulses", :force => true do |t|
    t.string   "category"
    t.string   "description"
    t.integer  "stars",       :default => 0
    t.integer  "user_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "adult",       :default => false, :null => false
  end

  add_index "pulses", ["user_id", "game_id"], :name => "index_pulses_on_user_id_and_game_id"

  create_table "ratings", :force => true do |t|
    t.integer "rater_id"
    t.integer "rated_id"
    t.string  "rated_type"
    t.decimal "rating"
  end

  add_index "ratings", ["rated_type", "rated_id"], :name => "index_ratings_on_rated_type_and_rated_id"
  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "text_link_ads_rss", :force => true do |t|
    t.string  "html",    :limit => 1024
    t.integer "post_id"
  end

  create_table "topics", :force => true do |t|
    t.string  "title"
    t.string  "icon"
    t.text    "description"
    t.boolean "active",      :default => true
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                                      :null => false
    t.string   "email",                                                      :null => false
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.string   "location",                                :default => ""
    t.string   "aim",                                     :default => ""
    t.string   "msn",                                     :default => ""
    t.string   "adsense",                                 :default => ""
    t.string   "website",                                 :default => ""
    t.string   "time_zone",                               :default => ""
    t.string   "signature",                               :default => ""
    t.string   "ip",                                      :default => ""
    t.datetime "remember_token_expires_at"
    t.boolean  "email_confirmed",                         :default => false
    t.boolean  "active",                                  :default => false
    t.boolean  "revenue_share",                           :default => false
    t.boolean  "banned",                                  :default => false
    t.boolean  "show_avatar",                             :default => true
    t.boolean  "show_email",                              :default => true
    t.integer  "views",                                   :default => 0
    t.integer  "gumpoints",                               :default => 0
    t.text     "about_me"
    t.datetime "age"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.integer  "permissions",                             :default => 0
  end

  add_index "users", ["login"], :name => "index_users_on_login"

  create_table "warnings", :force => true do |t|
    t.string   "title"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
