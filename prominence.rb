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
$front = [[$peak[1], $peak[2]]]
$visited = [[$peak[1], $peak[2]]]
$visited_before = []

def check_higher(position_with_ele)
  if position_with_ele[1] > $peak[0].to_f
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

def continue_spilling(new_front)
  $front = new_front.keys
  puts "Continue spilling with #{$front.size} positions"
  $visited += $front
  puts "Total visited #{$visited.size}"
end

def spilled_entirely_above
  puts "Spilled entirely above #{$ele}, total visited #{$visited.size}".light_green
  update_key_col(ARGV[0], $ele)
  $ele -= 1
  $front = [[$peak[1], $peak[2]]]
  $visited_before += $visited
  puts "$visited_before.size = #{$visited_before.size}"
  $visited = [[$peak[1], $peak[2]]]
end

while $ele > 0
  
  new_front = $front.map{|p| surrounding(p, 1)}.flatten(2).uniq - $visited
  # puts "new_front = #{new_front}"
  if new_front.size > 0
    # array of positions
    new_front = get_eles(new_front)
    # array of [position, elevation]
    # puts "new_front with elevations = #{new_front}"
    new_front = new_front.select{|p,ele| ele >= $ele}
    # puts "new_front with elevations above #{ele} = #{new_front}"
  end
  if new_front.size > 0
    max_in_new_front = new_front.max_by{|p,e| e}
    # Pair [position, elevation]
    # puts "max_in_new_front = #{max_in_new_front}"
    check_higher(max_in_new_front)
    continue_spilling(new_front)
  else
    spilled_entirely_above
  end
end


