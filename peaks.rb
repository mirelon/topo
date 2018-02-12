require_relative 'db.rb'
require 'colorize'
require 'byebug'

# Return peak id
def store_peak(position, elevation)
  peak_with_elevation = $db.get_first_row("SELECT id, elevation FROM peaks WHERE lat = #{position[0]} AND lng = #{position[1]};")
  if peak_with_elevation
    if peak_with_elevation[1] == elevation
      puts "Peak present in DB".light_black
      peak_with_elevation[0]
    else
      puts "Peak has elevation #{peak_with_elevation[1]} in DB, replacing with #{elevation}".light_red
      $db.execute("UPDATE peaks SET elevation = #{elevation} WHERE id = #{peak_with_elevation[0]};")
      peak_with_elevation[0]
    end
  else
    puts "Storing new peak".green
    $db.execute("INSERT INTO peaks(lat, lng, elevation) VALUES (#{position[0]}, #{position[1]}, #{elevation});")
    $db.get_first_value("SELECT last_insert_rowid();")
  end
end

def get_peak(id)
  where = id ? " WHERE id = #{id.to_i}" : ""
  $db.get_first_row("SELECT elevation, lat, lng FROM peaks#{where};")
end

def update_prominence(id, prominence, prominence_parent_id)
  puts "UPDATE peaks SET prominence_parent_id = #{prominence_parent_id}, prominence = #{prominence} WHERE id = #{id.to_i};"
  $db.execute("UPDATE peaks SET prominence_parent_id = #{prominence_parent_id}, prominence = #{prominence} WHERE id = #{id.to_i};")
end
