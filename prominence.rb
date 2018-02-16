require_relative 'hill_climbing.rb'
require 'colorize'

$peak = get_peak(ARGV[0])
if $peak.nil?
  puts "There is no peak with id #{ARGV[0]}"
  exit
end

puts "Starting with the peak with elevation #{$peak[0]}"

# Items consists of [elevation, position]
$ele = $peak[3] || $peak[0].to_i
$contour = [[$peak[1], $peak[2]]]
$visited = [[$peak[1], $peak[2]]]
$visited_before = []
$saddle = nil

def check_higher(position_with_ele)
  if position_with_ele[1] > $peak[0].to_f && !$saddle.nil?
    puts "Reached higher. Climbing to the prominence parent".light_green
    prominence_parent_position, prominence_parent_elevation, prominence_parent_id = climb(position_with_ele[0], 1)
    key_col = $ele + 1
    prominence = $peak[0].to_i - key_col
    if prominence < 0 then prominence = 0 end
    puts "Prominence data of #{$peak}:".light_green
    puts "Prominence parent: #{prominence_parent_id} at #{prominence_parent_position}, ele #{prominence_parent_elevation}".light_green
    puts "Key col: #{key_col}".light_green
    puts "Prominence: #{prominence}".light_green
    update_prominence(ARGV[0], prominence, prominence_parent_id)
    exit
  end
end

def check_saddle(position_with_ele)
  if position_with_ele[1] > $ele + 1 && !$visited_before.include?(position_with_ele[0]) && $saddle.nil?
    $saddle = position_with_ele
    puts "Found saddle #{$saddle}"
  end
end

def continue_spilling(new_contour)
  $contour = new_contour.keys
  puts "Continue spilling with #{$contour.size} positions"
  $visited += $contour
  puts "Total visited #{$visited.size}"
end

def spilled_entirely_above
  puts "Spilled entirely above #{$ele}, total visited #{$visited.size}".light_green
  update_key_col(ARGV[0], $ele)
  $ele -= 1
  $contour = [[$peak[1], $peak[2]]]
  $visited_before += $visited
  puts "$visited_before.size = #{$visited_before.size}"
  $visited = [[$peak[1], $peak[2]]]
  $saddle = nil
end

while $ele > 0
  
  new_contour = $contour.map{|p| surrounding(p, 1)}.flatten(2).uniq - $visited
  # puts "new_contour = #{new_contour}"
  if new_contour.size > 0
    # array of positions
    new_contour = get_eles(new_contour)
    # array of [position, elevation]
    # puts "new_contour with elevations = #{new_contour}"
    new_contour = new_contour.select{|p,ele| ele >= $ele}
    # puts "new_contour with elevations above #{ele} = #{new_contour}"
  end
  if new_contour.size > 0
    max_in_new_contour = new_contour.max
    # Pair [position, elevation]
    # puts "max_in_new_contour = #{max_in_new_contour}"
    check_saddle(max_in_new_contour)
    check_higher(max_in_new_contour)
    continue_spilling(new_contour)
  else
    spilled_entirely_above
  end
end


