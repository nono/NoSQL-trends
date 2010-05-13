#!/usr/bin/env ruby
require 'rubygems'
require 'twitter/json_stream'
require 'yaml'
require 'json'


cfg = YAML.load_file('config.yml')
keywords = cfg['keywords'].join(',').downcase


EventMachine::run do
  stream = Twitter::JSONStream.connect(
    :path    => "/1/statuses/filter.json",
    :auth    => "#{cfg['login']}:#{cfg['password']}",
    :method  => "POST",
    :content => "track=#{keywords}"
  )

  stream.each_item do |item|
    $stdout.print "item: #{item}\n"
    data = JSON.parse(item)
    $stdout.print "#{data}\n"
    $stdout.flush
  end

  stream.on_error do |message|
    $stderr.print "error: #{message}\n"
  end

  stream.on_max_reconnects do |timeout, retries|
    $stderr.print "Failed after #{retries} failed reconnects\n"
  end

  trap('TERM') do
    stream.stop
    EventMachine.stop if EventMachine.reactor_running?
  end
end
