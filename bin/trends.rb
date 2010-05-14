#!/usr/bin/env ruby
require 'rubygems'
require 'trends'

EventMachine::run do
  trends = Trends.new(ARGV[0] || "config/config.yml")
  trends.twitter_stream
  trends.mongo

  trap('HUP') do
    reload
  end

  trap('TERM') do
    trends.stop
    EventMachine.stop if EventMachine.reactor_running?
  end
end
