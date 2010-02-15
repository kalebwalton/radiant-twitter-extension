# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'
require File.join(File.dirname(__FILE__), 'vendor/plugins/twitter/lib/twitter')
require File.join(File.dirname(__FILE__), 'vendor/plugins/bitly/lib/bitly')
class TwitterExtension < Radiant::Extension
  version "1.1"
  description "Posts notification of pages to Twitter."
  url "http://github.com/seancribbs/radiant-twitter-extension"

  define_routes do |map|
  end
  
  def activate
    admin.pages.edit.add :extended_metadata, "twitter"
    Page.class_eval { include TwitterNotification, TwitterTags }
    
    if admin.respond_to?(:help)
      admin.help.index.add :page_details, 'twitter'
    end
  end
end
