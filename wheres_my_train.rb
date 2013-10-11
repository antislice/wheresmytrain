#!/usr/bin/ruby -w
require 'nokogiri'
require 'open-uri'
require 'CSV'
require 'twilio-ruby'
require 'yaml'

def todays_dep_time(dep_time)
	today = Time.now
	dep_time_arr = dep_time.split(':')
	Time.new(today.year, today.month, today.day, dep_time_arr[0], dep_time_arr[1])
end

def get_trip_id(num)
	csv = CSV.parse(File.read('google_transit_static_devs/trips.txt'), headers: true)
	csv.find {|trip| trip['trip_short_name'] == num}['trip_id']
end

def get_stop_time(trip_id, station)
	csv = CSV.parse(File.read('google_transit_static_devs/stop_times.txt'), headers: true)
	stop_time = csv.find {|stop| stop['trip_id'] == trip_id and stop['stop_id'].downcase.include? station}
	todays_dep_time(stop_time['departure_time'])
end

def sec_to_min(seconds)
	seconds / 60
end

def min_to_sec(minutes)
	minutes * 60
end

def on_time?(scheduled_time, expected_time)
	difference = scheduled_time - expected_time
	return false if difference < -5 * 60
	true
end

station = ARGV.first
train_num = ARGV.last

trip_id = get_trip_id(train_num)

if trip_id.nil?
	puts "train #{train_num} doesn't exist!"
	exit
end

doc = Nokogiri::HTML(open("http://www.caltrain.com/schedules/realtime/stations/#{station}station-mobile.html"))
train_entry = doc.css('tr.ipf-st-ip-trains-subtable-tr').find do |train| 
	train.css('td.ipf-st-ip-trains-subtable-td-id').first.content == train_num
end

if train_entry.nil?
 puts "train #{train_num} is not departing within the next 90 minutes"
 exit
end

wait_mins = train_entry.css('td.ipf-st-ip-trains-subtable-td-arrivaltime').first.content.split.first.to_i
scheduled_arrival = get_stop_time(trip_id, station)
expected_arrival = Time.now + min_to_sec(wait_mins)

unless (on_time?(scheduled_arrival, expected_arrival))
	CONFIG = YAML.load_file('config.yml')
	account_sid = CONFIG['twilio']['SID']
	auth_token = CONFIG['twilio']['token']
	client = Twilio::REST::Client.new account_sid, auth_token
 
	client.account.sms.messages.create(
    :from => "+#{CONFIG['phone']['from']}",
    :to => "+#{CONFIG['phone']['to']}",
    :body => "Caltrain #{train_num} is late! Expected arrival at #{station} is #{expected_arrival.strftime('%I:%M')}"
  ) 
  puts "Sent message about late train #{train_num}"
end