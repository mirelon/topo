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
$color_scale = [[0, 220, 190, 150, 130], [150, 220, 110, 0, 130], [0, 0, 0, 0, 130], [255, 255, 255, 255, 255]]
$png = ChunkyPNG::Image.from_file('elevations.png')

puts "Min elevation = #{$minele}, max elevation = #{$maxele}"

def get_color(ele)
  # puts "Getting color for elevation #{ele}".light_black
  ele_normalized = (ele - $minele) / ($maxele - $minele)
  color = $color_scale.map do |scale|
            if ele_normalized < 0.25
              (ele_normalized * 4 * (scale[1] - scale[0]) + scale[0]).round
            elsif ele_normalized < 0.5
              ((ele_normalized - 0.25) * 4 * (scale[2] - scale[1]) + scale[1]).round
            elsif ele_normalized < 0.75
              ((ele_normalized - 0.5) * 4 * (scale[3] - scale[2]) + scale[2]).round
            else
              ((ele_normalized - 0.75) * 4 * (scale[4] - scale[3]) + scale[3]).round
            end
            
          end
  color
end

def get_pixel_position(position)
  # puts "Getting pixel position for #{position}".light_black
  pixel_position = [(10000 * (position[1] - $minlng)).round, $height - (10000 * (position[0] - $minlat)).round - 1]
  pixel_position
end

def render_all
  puts "Creating PNG, width = #{$width}, height = #{$height}"
  $png = ChunkyPNG::Image.new($width, $height, ChunkyPNG::Color::TRANSPARENT)
  elevations = $db.execute("SELECT lat, lng, ele FROM elevations;")
  elevations.each do |lat, lng, ele|
    store_elevations_to_png([[lat, lng, ele]])
  end
  save_and_open_in_browser
end

def store_elevations_to_png(elevations)
  elevations.each do |lat, lng, ele|
    $png[*get_pixel_position([lat, lng])] = ChunkyPNG::Color.rgba(*get_color(ele))
  end
end

def save_and_open_in_browser
  $png.save('elevations.png', :interlace => false)
  puts "PNG saved"
  system("google-chrome elevations.png")
end



