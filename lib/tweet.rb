require "json"


class Tweet
  class <<self
    attr_accessor :collection
  end
  attr_accessor :keywords

  def intialize(item)
    data  = JSON.parse(item)
    @id   = data["id"]
    @user = data["user"]["screen_name"]
    @text = data["text"]
  end

  def to_s
    "#{@user} #{@text}"
  end

  def save
    Tweet.collection.insert(
      :id       => @id,
      :user     => @user,
      :text     => @text,
      :keywords => @keywords
    )
  end
end
