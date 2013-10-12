require 'json'
require 'nokogiri'
require 'open-uri'
require 'CSV'
require_relative 'station'

class Caltrain

	def self.get_trip_id(train_num)
		csv = CSV.parse(File.read('google_transit_static_devs/trips.txt'), headers: true)
		csv.find {|trip| trip['trip_short_name'] == train_num}['trip_id']
	end

	def self.find_station(station_str)
		stations_list = JSON.parse(File.read('stations.json'))
		station = stations_list.find{|st| st['name'] == station_str}
		!station.nil? ? Station.new(station) : nil
	end

	def self.on_time?(scheduled_time, expected_time)
		difference = scheduled_time - expected_time
		return false if difference < -5 * 60
		true
	end

end