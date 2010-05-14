require 'twitter/json_stream'
require 'yaml'
require 'json'
require 'classify'


class Trends
  def initialize(config_file)
    @config_file = config_file
    reload
  end

  def reload
    cfg = YAML.load_file(@config_file)
    @login    = cfg['login']
    @password = cfg['password']
    @retweet  = cfg['retweet']
    @keywords = cfg['keywords']
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
      data  = JSON.parse(item)
      txt   = "#{data["user"]["screen_name"]} #{data["text"]}"
      words = classify.results(txt)
      puts "#{txt} --> #{words.join(' - ')}"
    end

    @stream.on_error do |message|
      puts "error: #{message}"
    end

    @stream.on_max_reconnects do |timeout, retries|
      puts "Failed after #{retries} failed reconnects"
    end
  end

  def stop
    @stream.stop
  end
end
