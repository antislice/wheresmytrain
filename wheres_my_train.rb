#!/usr/bin/ruby -w
require 'nokogiri'
require 'open-uri'
require_relative '511_api'

#doc = Five11.get_routes_for_agency('Caltrain')
# doc = Five11.get_stops_for_route('Caltrain', 'LIMITED', 'NB')
doc = Five11.get_next_departures_for_stop('70111')
puts doc

#puts doc.css("Agency").find {|n| n.attributes["Name"].value == "Caltrain"}
