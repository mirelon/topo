require_relative 'db.rb'
require 'colorize'
require 'byebug'

def store_peak(position, elevation)
  puts "SELECT * FROM peaks WHERE lat = #{position[0]} AND lng = #{position[1]};"
  peak_elevation = $db.get_first_value("SELECT elevation FROM peaks WHERE lat = #{position[0]} AND lng = #{position[1]};")
  if peak_elevation
    if peak_elevation == elevation
      puts "Peak present in DB".light_black
    else
      puts "Peak has elevation #{peak.elevation} in DB, replacing with #{elevation}".orange
      $db.execute("UPDATE peaks SET elevation = #{elevation} WHERE lat = #{position[0]} AND lng = #{position[1]};")
    end
  else
    puts "Storing new peak".green
    $db.execute("INSERT INTO peaks(lat, lng, elevation) VALUES (#{position[0]}, #{position[1]}, #{elevation});")
  end
end
