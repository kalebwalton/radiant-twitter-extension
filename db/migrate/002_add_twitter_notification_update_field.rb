class AddTwitterNotificationUpdateField < ActiveRecord::Migration
  def self.up
    add_column :pages, :notify_twitter_of_children_updates, :boolean, :default => false
  end
  
  def self.down
    remove_column :pages, :notify_twitter_of_children_updates
  end
end