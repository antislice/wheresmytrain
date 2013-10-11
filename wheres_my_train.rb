#!/usr/bin/ruby -w
require 'nokogiri'
require 'open-uri'
require 'CSV'

def get_trip_id(num)
	csv = CSV.parse(File.read('google_transit_static_devs/trips.txt'), headers: true)
	csv.find {|trip| trip['trip_short_name'] == num}
end

def get_stop_time(trip_id, station)
	csv = CSV.parse(File.read('google_transit_static_devs/stop_times.txt'), headers: true)
	puts csv.headers
	stop_time = csv.find {|stop| stop['\xEF\xBB\xBFtrip_id'] == trip_id and stop['stop_id'].downcase.include? station}
	stop_time['departure_time'].strftime("%I:%M:%S")
end

station = ARGV.first
train_num = ARGV.last

if get_trip_id(train_num).nil?
	puts "train #{train_num} doesn't exist!"
	exit
end

#doc = Nokogiri::HTML(open("http://www.caltrain.com/schedules/realtime/stations/#{station}station-mobile.html"))
doc = Nokogiri::HTML(open("hillsdalemobile.html"))
train_entry = doc.css('tr.ipf-st-ip-trains-subtable-tr').find do |train| 
	train.css('td.ipf-st-ip-trains-subtable-td-id').first.content == train_num
end

if train_entry.nil?
 puts "train #{train_num} is not departing within the next 90 minutes"
 exit
end

wait_mins = train_entry.css('td.ipf-st-ip-trains-subtable-td-arrivaltime').first.content.split.first.to_i
puts wait_mins
puts get_stop_time(get_trip_id(train_num), station)
puts "time now: #{Time.now}, time plus expected wait: #{Time.now + (wait_mins * 60)}"

# AW YEAH FUNKY CHARACTERS IN THE TXT! (in headers for stop_times.txt, must filter)
