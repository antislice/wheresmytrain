#!/usr/bin/ruby -w
require 'twilio-ruby'
require 'yaml'
require_relative 'caltrain'

def sec_to_min(seconds)
	seconds / 60
end

def min_to_sec(minutes)
	minutes * 60
end

def clean_and_validate_station(station_str)
	station_str = station_str.downcase.chomp
	station = Caltrain.find_station(station_str)
	if station.nil?
		puts "station #{station_str} doesn't exist!"
		exit
	end
	station
end

station = clean_and_validate_station(ARGV.first)
train_num = ARGV.last

trip_id = Caltrain.get_trip_id(train_num)

if trip_id.nil?
	puts "train #{train_num} doesn't exist!"
	exit
end

wait_mins = station.wait_time_for(train_num)
exit if wait_mins.nil?
scheduled_arrival = station.get_stop_time(trip_id)
expected_arrival = Time.now + min_to_sec(wait_mins)

unless (Caltrain.on_time?(scheduled_arrival, expected_arrival))
	CONFIG = YAML.load_file('config.yml')
	account_sid = CONFIG['twilio']['SID']
	auth_token = CONFIG['twilio']['token']
	client = Twilio::REST::Client.new account_sid, auth_token
 
	client.account.sms.messages.create(
    :from => "+#{CONFIG['phone']['from']}",
    :to => "+#{CONFIG['phone']['to']}",
    :body => "Caltrain #{train_num} is late! Expected arrival at #{station['stop_id']} is #{expected_arrival.strftime('%I:%M')}"
  ) 
  puts "Sent message about late train #{train_num}"
end