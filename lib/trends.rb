require "twitter/json_stream"
require "em-mongo"
require "classify"
require "tweet"
require "yaml"


class Trends
  def initialize(config_file)
    @config_file = config_file
    reload
  end

  def reload
    cfg = YAML.load_file(@config_file)
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
      tweet = Tweet.new(item)
      tweet.keywords = @classify.results(tweet.to_s)
      puts "#{tweet} --> #{tweet.keywords.join(' - ')}"
      tweet.save
    end

    @stream.on_error { |msg| puts "error: #{msg}" }
    @stream.on_max_reconnects { |_,nb| puts "Failed after #{nb} failed reconnects" }
  end

  def mongo
    db = EM::Mongo::Connection.new.db(@database)
    Tweet.collection = db.collection('tweets')
  end

  def stop
    @stream.stop
  end
end
