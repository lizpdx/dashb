#!/usr/bin/env ruby
require 'json'
require 'curb'
#require 'date'
#require 'time'

@euc = "https://community.elementaltechnologies.com/api/core/v3"
@username = ENV["JIVE_USERNAME"]
@password = ENV["JIVE_PASSWORD"]
@curl = Curl::Easy.new
@curl.verbose = true
@curl.ssl_verify_peer = false
@curl.headers = {"Accept" => "application/json", "Content-Type" => "application/json"}
@curl.username = @username
@curl.password = @password
@curl.url = @euc+'/contents/recent?filter=type(discussion)&=filter=entityDescriptor(14,1001)&count=5'

SCHEDULER.every '1m', :first_in => 0 do |job|

  @curl.get

  response = @curl.body_str.gsub( /throw 'allowIllegalResourceCall is false.';/, '' )
  @results = JSON.parse( response, :symbolize_names => true )
  @VIEWS = @results[:list]
  #@VIEWS.each { |item| data = item[:subject] + " - " +  item[:author][:displayName]  + " ("+ item[:author][:published][0,10]+")" }

  data = @VIEWS.map{|c| {label: c[:subject] , value: c[:author][:displayName]}}

  send_event( "jive", { items: data })
end
