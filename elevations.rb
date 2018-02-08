require_relative 'db.rb'
require 'google_maps_service'
require 'byebug'
require 'colorize'

def get_ele_from_db(position)
  begin
    ele = $db.get_first_value("SELECT ele FROM elevations WHERE lat = #{position[0]} AND lng = #{position[1]};")
    if ele
      puts "Present #{position} in DB: #{ele}".light_black
      ele
    else
      puts "Missing #{position} in DB".light_black
    end
  rescue SQLite3::Exception => e
    puts "Exception occured:"
    puts e
  end
end

def cache_ele_from_google(position)
  gmaps = GoogleMapsService::Client.new(key: 'AIzaSyCJ5O4JK9TdWQVOqa4u5ESQi_K0n-7wlzQ')
  elevations = gmaps.elevation([position])
  ele = elevations[0][:elevation]
  puts "Caching #{ele} for #{position}"
  $db.execute("INSERT INTO elevations(lat, lng, ele) VALUES (#{position[0]}, #{position[1]}, #{ele})")
  ele
end

def get_ele(position)
  get_ele_from_db(position) || cache_ele_from_google(position)
end
