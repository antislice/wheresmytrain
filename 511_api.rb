require 'nokogiri'
require 'open-uri'

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

	TOKEN = "your-token-here"

end