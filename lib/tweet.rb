require "json"
require "oauth"
require "em-http"
require 'oauth/client/em_http'


# A tweet is a simple object created from the twitter stream
# and that can be stored in a MongoDB collection.
#
class Tweet
  class <<self
    attr_accessor :collection   # The MongoDB collection where tweets are saved
    attr_accessor :credentials  # The OAuth credentials for twitter

    def twitter_oauth_consumer
      @twitter_oauth_consumer ||= OAuth::Consumer.new(@credentials["consumer_key"], @credentials["consumer_secret"], :site => "http://api.twitter.com")
    end

    def twitter_oauth_access_token
      @twitter_oauth_access_token ||= OAuth::AccessToken.new(twitter_oauth_consumer, @credentials["access_token"], @credentials["access_token_secret"])
    end
  end

  attr_accessor :id             # The tweet id from twitter
  attr_accessor :user           # The username
  attr_accessor :text           # The text of the tweet
  attr_accessor :keywords       # The associated keywods that counts for trending

  # Create a tweet from a JSON item
  def self.from_stream(item)
    data  = JSON.parse(item)
    tweet = Tweet.new
    tweet.id   = data["id"]
    tweet.user = data["user"]["screen_name"]
    tweet.text = data["text"]
    tweet
  end

  def retweet
    return false unless Tweet.credentials["retweet"]
    url = "http://api.twitter.com/1/statuses/retweet/#{@id}.json"
    request = EventMachine::HttpRequest.new(url)
    http = request.post do |client|
      Tweet.twitter_oauth_consumer.sign!(client, Tweet.twitter_oauth_access_token)
    end
  end

  # Save this tweet to MongoDB
  def save
    Tweet.collection.insert(
      :tweet_id   => @id,
      :user       => @user,
      :text       => @text,
      :keywords   => @keywords,
      :created_at => Date.today.to_s
    )
  end

  # String representation
  def to_s
    "@#{@user} #{@text}"
  end
end
