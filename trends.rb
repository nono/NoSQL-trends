#!/usr/bin/env ruby
require 'rubygems'
require 'twitter/json_stream'
require 'yaml'
require 'json'
require 'classify'


cfg = YAML.load_file('config.yml')
keywords = cfg['keywords'].join(',').downcase
classify = Classify.new(cfg['keywords'])
classify.train


EventMachine::run do
  stream = Twitter::JSONStream.connect(
    :path    => "/1/statuses/filter.json",
    :auth    => "#{cfg['login']}:#{cfg['password']}",
    :method  => "POST",
    :content => "track=#{keywords}"
  )

  stream.each_item do |item|
    data  = JSON.parse(item)
    txt   = "#{data["user"]["screen_name"]} #{data["text"]}"
    words = classify.results(txt)
    puts "#{txt} --> #{words.join(' - ')}"
  end

  stream.on_error do |message|
    puts "error: #{message}"
  end

  stream.on_max_reconnects do |timeout, retries|
    puts "Failed after #{retries} failed reconnects"
  end

  trap('TERM') do
    stream.stop
    EventMachine.stop if EventMachine.reactor_running?
  end
end
