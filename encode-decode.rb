# helper script used to surface bad characters I found at the beginning of the caltrain txt files
string = File.read("google_transit_static_devs/#{ARGV.first}.txt")
puts string.encoding
string.encode!('UTF-8', :undef => :replace, :invalic => :replace, :replace => "")
# string.encode!('UTF-8')
puts string.encoding
File.open("google_transit_static_devs/#{ARGV.first}.txt", 'w') {|f|
	f.puts string
}
