class Station

	attr_reader :url, :stop_id

	def initialize(station_hash)
		@url = station_hash['url']
		@stop_id = station_hash['stop_id']
	end

	def stop_time_for_trip(trip_id)
		csv = CSV.parse(File.read('google_transit_static_devs/stop_times.txt'), headers: true)
		stop_time = csv.find {|stop| stop['trip_id'] == trip_id and stop['stop_id'] == @stop_id}
		todays_dep_time(stop_time['departure_time'])
	end

	def wait_time_for(train_num)
		# doc = Nokogiri::HTML(open("http://www.caltrain.com/schedules/realtime/stations/#{@url}station-mobile.html"))
		doc = Nokogiri::HTML(open("hillsdalemobile.html"))
		train_entry = doc.css('tr.ipf-st-ip-trains-subtable-tr').find do |train| 
			train.css('td.ipf-st-ip-trains-subtable-td-id').first.content == train_num
		end

		if train_entry.nil?
			puts "train #{train_num} is not departing #{@stop_id} within the next 90 minutes"
		 	return
		end
		train_entry.css('td.ipf-st-ip-trains-subtable-td-arrivaltime').first.content.split.first.to_i
	end

	private
	def todays_dep_time(dep_time)
		today = Time.now
		dep_time_arr = dep_time.split(':')
		Time.new(today.year, today.month, today.day, dep_time_arr[0], dep_time_arr[1])
	end
end