require "yaml"
require "thin"
require "tweet"
require "twitter/json_stream"
require "em-mongo"
require "classify"
require "web_adapter"


# Trends is the core of this application.
# It manages the interaction between the twitter stream,
# the classifier and the Mongo database.
#
class Trends
  def initialize(config_file)
    @config_file = config_file
    reload
  end

  def reload
    cfg = YAML.load_file(@config_file)
    @port     = cfg["port"]
    @login    = cfg["login"]
    @password = cfg["password"]
    @retweet  = cfg["retweet"]
    @keywords = cfg["keywords"]
    @database = cfg["mongodb"]
    @classify = Classify.new(@keywords)
    @classify.train
  end

  def twitter_stream
    track = @keywords.join(',').downcase
    @stream = Twitter::JSONStream.connect(
      :path    => "/1/statuses/filter.json",
      :auth    => "#{@login}:#{@password}",
      :method  => "POST",
      :content => "track=#{track}"
    )

    @stream.each_item do |item|
      tweet = Tweet.from_stream(item)
      tweet.keywords = @classify.results(tweet.to_s)
      tweet.save
      puts "#{tweet} --> #{tweet.keywords.join(' - ')}"
    end

    @stream.on_error { |msg| puts "error: #{msg}" }
    @stream.on_max_reconnects { |_,nb| puts "Failed after #{nb} failed reconnects" }
  end

  def mongo
    db = EM::Mongo::Connection.new.db(@database)
    WebAdapter.collection = Tweet.collection = db.collection('tweets')
  end

  def web
    WebAdapter.keywords = @keywords
    Thin::Server.start('127.0.0.1', @port) do
      use Rack::CommonLogger
      map '/' do
        run WebAdapter.new
      end
    end
  end

  def stop
    @stream.stop
  end
end
