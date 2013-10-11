require 'nokogiri'
require 'open-uri'

# doc = Five11.get_routes_for_agency('Caltrain')
# doc = Five11.get_stops_for_route('Caltrain', 'LIMITED', 'NB')
# doc = Five11.get_next_departures_for_stop('70111') # Hillsdale stop NB
# see http://511.org/docs/RTT%20API%20V2.0%20Reference.pdf for reference on API

class Five11

	def self.get_agencies
		Nokogiri::XML(open(api_url("GetAgencies")))
	end

	def self.get_routes_for_agency(agency)
		Nokogiri::XML(open(api_url("GetRoutesForAgency") + "&agencyName=#{agency}"))
	end

	def self.get_stops_for_route(agency, route_code, route_dir)
		route_IDF = "#{agency}~#{route_code}"
		route_IDF << "~#{route_dir}" unless route_dir.nil?
		Nokogiri::XML(open(api_url("GetStopsForRoute") + "&routeIDF=#{route_IDF}"))
	end

	def self.get_next_departures_for_stop(stop_code)
		Nokogiri::XML(open(api_url("GetNextDeparturesByStopCode") + "&stopcode=#{stop_code}"))
	end

	private 
	def self.api_url(method)
		"http://services.my511.org/Transit2.0/#{method}.aspx?token=#{TOKEN}"
	end

	# use your own token here
	TOKEN = "87653c24-22de-4ea8-b3c2-3946b3cb2caa"

end