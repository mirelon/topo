require_relative 'peaks'
require 'gpx'

gpx = GPX::GPXFile.new
get_all_peaks.each do |elevation, prominence, lat, lng|
  gpx.waypoints << GPX::Waypoint.new({name: "(#{elevation.round(2)}, #{prominence})", lat: lat, lon: lng})
end
puts gpx.to_s