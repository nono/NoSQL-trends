require "mustache"


class WebAdapter < Mustache
  AsyncResponse = [-1, {}, []].freeze

  self.template_file = 'views/home.mustache'

  class <<self
    attr_accessor :collection  # The MongoDB collection where tweets are saved
    attr_accessor :keywords    # The tracked keywords
  end

  attr_reader :tweets

  def call(env)
    with_tweets do
      env['async.callback'].call [ 200, { "Content-Type" => "text/html; charset=utf-8" }, [render] ]
    end
    AsyncResponse
  end

  def stylesheet
    static_url "styles.css"
  end

  def favicon
    static_url "favicon.png"
  end

  def keywords
    self.class.keywords.join(', ')
  end

protected

  def static_url(file)
    timestamp = File.stat("public/#{file}").mtime.to_i
    "/#{file}?#{timestamp}"
  end

  def with_tweets(&blk)
    self.class.collection.find do |res|
      @tweets = res
      yield
    end
  end
end
