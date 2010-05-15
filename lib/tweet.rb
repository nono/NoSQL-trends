require "json"


# A tweet is a simple object created from the twitter stream
# and that can be stored in a MongoDB collection.
#
class Tweet
  class <<self
    attr_accessor :collection  # The MongoDB collection where tweets are saved
  end

  attr_accessor :id            # The tweet id from twitter
  attr_accessor :user          # The username
  attr_accessor :text          # The text of the tweet
  attr_accessor :keywords      # The associated keywods that counts for trending

  # Create a tweet from a JSON item
  def self.from_stream(item)
    data  = JSON.parse(item)
    tweet = Tweet.new
    tweet.id   = data["id"]
    tweet.user = data["user"]["screen_name"]
    tweet.text = data["text"]
    tweet
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
