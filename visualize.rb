require_relative 'db.rb'
require 'chunky_png'

$maxlat = $db.get_first_value("SELECT max(lat) FROM elevations;")
$minlat = $db.get_first_value("SELECT min(lat) FROM elevations;")
$maxlng = $db.get_first_value("SELECT max(lng) FROM elevations;")
$minlng = $db.get_first_value("SELECT min(lng) FROM elevations;")
$minele = $db.get_first_value("SELECT min(ele) FROM elevations;")
$maxele = $db.get_first_value("SELECT max(ele) FROM elevations;")
$width = (10000 * ($maxlng - $minlng) + 1).round
$height = (10000 * ($maxlat - $minlat) + 1).round
$color_scale = [[0, 220, 150], [150, 220, 0], [0, 0, 0], [255, 255, 255]]

puts "Min elevation = #{$minele}, max elevation = #{$maxele}"

def get_color(ele)
  puts "Getting color for elevation #{ele}"
  ele_normalized = (ele - $minele) / ($maxele - $minele)
  color = $color_scale.map do |scale|
            if ele_normalized < 0.5
              (ele_normalized * 2 * (scale[1] - scale[0]) + scale[0]).round
            else
              ((ele_normalized - 0.5) * 2 * (scale[2] - scale[1]) + scale[1]).round
            end
            
          end
  puts color.inspect
  color
end

def get_pixel_position(position)
  puts "Getting pixel position for #{position}"
  pixel_position = [(10000 * (position[1] - $minlng)).round, $height - (10000 * (position[0] - $minlat)).round - 1]
  puts pixel_position.inspect
  pixel_position
end

puts "Creating PNG, width = #{$width}, height = #{$height}"
png = ChunkyPNG::Image.new($width, $height, ChunkyPNG::Color::TRANSPARENT)

elevations = $db.execute("SELECT lat, lng, ele FROM elevations;")
elevations.each do |lat, lng, ele|
  png[*get_pixel_position([lat, lng])] = ChunkyPNG::Color.rgba(*get_color(ele))
end

png.save('elevations.png', :interlace => false)
puts "PNG saved"
system("google-chrome elevations.png")
