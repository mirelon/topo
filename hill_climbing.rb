require_relative 'elevations.rb'
require_relative 'peaks.rb'
require_relative 'surrounding.rb'
require 'byebug'
require 'colorize'

# Find the maximal position inside the circle around position with the given radius
# Return a quintuple [max_radius, max_position, max_elevation, increase, my_elevation]
def highest_neighbor(position, radius)
  all_positions = [[position]] + surrounding(position, radius)
  my_elevation = get_ele(position)
  neighbor_elevations = surrounding(position, radius).map do |positions_on_r|
                          get_eles(positions_on_r).values
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

# Return a triple [position. elevation, ID]
def climb(position, radius)
  max_rad, max_pos, max_ele, inc, my_ele = highest_neighbor(position, radius)
  if inc < 0 || max_rad < radius
    puts "We have reached the peak (#{my_ele}) at #{position}".green
    peak_id = store_peak(position, my_ele)
    [position, my_ele, peak_id]
  else
    puts "Elevation #{max_ele}, position #{max_pos}".yellow
    sleep 0.01
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