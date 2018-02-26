require_relative 'visualize.rb'
require 'google_maps_service'
require 'byebug'
require 'colorize'

def get_eles_from_google(positions)
  gmaps = GoogleMapsService::Client.new(key: 'AIzaSyCJ5O4JK9TdWQVOqa4u5ESQi_K0n-7wlzQ')
  gmaps.elevation(positions)
end

def get_ele_from_db(position)
  ele = $db.get_first_value("SELECT ele FROM elevations WHERE lat = #{position[0]} AND lng = #{position[1]};")
  if ele
    puts "Present #{position} in DB: #{ele}".light_black
    ele
  else
    puts "Missing #{position} in DB".light_black
  end
end

def cache_ele_from_google(position)
  ele = get_eles_from_google([position])[0][:elevation]
  puts "Caching #{ele} for #{position}"
  $db.execute("INSERT INTO elevations(lat, lng, ele) VALUES (#{position[0]}, #{position[1]}, #{ele})")
  store_elevations_to_png([[position[0], position[1], ele]])
  ele
end

def get_ele(position)
  get_ele_from_db(position) || cache_ele_from_google(position)
end

def get_eles_from_db(positions)
  positions_as_string = positions.map{|p| "'#{p[0]}-#{p[1]}'"}.join(", ")
  eles = $db.execute("SELECT lat, lng, ele FROM elevations WHERE lat || '-' || lng IN (#{positions_as_string});")
  eles
end

# Return hash {position => elevation}
def get_eles(positions)
  e = positions.each_slice(320).map{|p| get_eles2(p)}.reduce(:merge)
end

def get_eles2(positions)
  eles = positions.map{|p| [p, nil]}.to_h 
  puts "Requesting #{positions.size} positions".light_black
  get_eles_from_db(positions).each{|lat, lng, ele| eles[[lat, lng]] = ele}
  missing = eles.select{|p,ele| ele.nil?}
  if missing.size > 0
    puts "Missing #{missing.size} positions".light_blue
    values = get_eles_from_google(missing.keys).map do |position_data|
               ele = position_data[:elevation]
               lat = position_data[:location][:lat]
               lng = position_data[:location][:lng]
               eles[[lat, lng]] = ele
               [lat, lng, ele]
             end
    if values
      puts "Caching #{values.size} elevations".light_black
      $db.execute("INSERT INTO elevations(lat, lng, ele) VALUES #{values.map{|lat, lng, ele| "(#{lat}, #{lng}, #{ele})"}.join(',')};")
      # store_elevations_to_png(values)
    else
      puts "No elevations returned from Google API"
    end
  else
    puts "All of the positions are in DB".light_black
  end
  eles
end
