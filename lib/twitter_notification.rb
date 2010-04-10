require 'twitter'
require 'bitly'
module TwitterNotification
  def self.included(base)
    base.class_eval {
      after_save :notify_twitter
    }
  end
  
  def notify_twitter
    if parent
      if published? && twitter_configured? && parent.notify_twitter_of_children? && (parent.notify_twitter_of_children_updates? || !self.twitter_id)
        bitly = Bitly.new(radiant_config['bitly.username'], radiant_config['bitly.api_key'])
        bitly_url = bitly.shorten(absolute_url, :history => 1)
        message_intro = "Webpage '"
        url = bitly_url.jmp_url
        title_length = 131 -message_intro.length - url.length
        message_title = title.length > title_length ? (title[0..title_length-4] + "...") : title
        message = "#{message_intro}#{message_title}' updated: #{url}"
        begin
          site = Site.current_site
          httpauth = Twitter::HTTPAuth.new(site.twitter_username, site.twitter_password)
          client = Twitter::Base.new(httpauth)
          status = client.update(message, :source => "outrighteouswebsite")
          # Don't trigger save callbacks
          self.class.update_all({:twitter_id => status.id}, :id => self.id)
        rescue Exception => e
          # Twitter failed... just log for now
          logger.error "Twitter Notification failure: #{e.inspect}"
        end
      end
    end
    true
  end

  def absolute_url
    raise "Couldn't find site" if Site.current_site.nil?
    site = Site.current_site
    site_hostname = site.hostname.split(',')[0].strip # Get the first site in the list as it's the primary
    if site_hostname =~ /^http/
      "#{site_hostname}#{self.url}"
    else
      "http://#{site_hostname}#{self.url}"
    end
  end

  def twitter_configured?
    raise "Couldn't find site" if Site.current_site.nil?
    site = Site.current_site
    !site.twitter_username.nil? && !site.twitter_password.nil? && !site.hostname.nil?
  end

  def radiant_config
    Radiant::Config
  end
end
