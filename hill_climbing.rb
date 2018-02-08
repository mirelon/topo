require_relative 'get_ele.rb'
require 'byebug'
require 'colorize'

# Return array of arrays
# Outer arrays is "by the radius"
# Inner array consists of positions on the given radius
def surrounding(position, radius)
  dlat = 0.0001
  dlng = 0.0001
  (1..radius).map do |r|
    (-r..r).map do |rlat|
      points = [[position[0] + dlat * rlat, position[1] + dlng * (r - rlat.abs)]]
      if rlat.abs != r
        points += [[position[0] + dlat * rlat, position[1] + dlng * (rlat.abs - r)]]
      end
      points
    end.flatten(1)
  end
end

def highest_neighbor(position, radius)
  all_positions = [[position]] + surrounding(position, radius)
  my_elevation = get_ele(position)
  neighbor_elevations = surrounding(position, radius).map do |positions_on_r|
                          positions_on_r.map do |p|
                            get_ele(p)
                          end
                        end
  max_ele_for_radiuses_and_index = ([0] + neighbor_elevations.map(&:max)).each_with_index.max
  max_elevation = max_ele_for_radiuses_and_index[0]
  max_radius = max_ele_for_radiuses_and_index[1]
  max_position = if max_radius == 0
                   puts "Negative elevation?"
                   my_position
                 else
                   max_ele_index_on_radius = neighbor_elevations[max_radius - 1].each_with_index.max[1]
                   all_positions[max_radius][max_ele_index_on_radius]
                 end
  increase = max_elevation - my_elevation
  puts "Among the neighbors the highest is on radius #{max_ele_for_radiuses_and_index[1]}, position #{max_position} with elevation #{max_elevation}, increase = #{increase}"
  [max_radius, max_position, max_elevation, increase, my_elevation]
end

def climb(position, radius)
  max_rad, max_pos, max_ele, inc, my_ele = highest_neighbor(position, radius)
  if inc < 0 || max_rad < radius
    puts "We have reached the peak (#{my_ele}) at #{position}".green
  else
    puts "Elevation #{max_ele}".yellow
    sleep 0.2
    if inc > 0
      puts "Climbing more".light_black
      climb(max_pos, 1)
    else
      new_radius = radius + 1
      puts "On a flat, increasing radius to #{new_radius}"
      climb(max_pos, new_radius)
    end
  end
end