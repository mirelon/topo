require_relative 'hill_climbing.rb'
require 'colorize'

peak = get_peak(ARGV[0])
if peak.nil?
  puts "There is no peak with id #{ARGV[0]}"
  exit
end

puts "Starting with the peak with elevation #{peak[0]}"

# Items consists of [elevation, position]
$ele = peak[0].to_i
$contour = [[peak[1], peak[2]]]
$visited = [[peak[1], peak[2]]]
$visited_before = []
while $ele > 0
  new_contour = $contour.map{|p| surrounding(p, 1)}.flatten(2).uniq - $visited
  # puts "new_contour = #{new_contour}"
  if new_contour.size > 0
    new_contour = get_eles(new_contour)
    # puts "new_contour with elevations  = #{new_contour}"
    new_contour = new_contour.select{|p,ele| ele >= $ele}
    # puts "new_contour with elevations above #{ele} = #{new_contour}"
  end
  if new_contour.size > 0
    max_in_new_contour = new_contour.max
    # puts "max_in_new_contour = #{max_in_new_contour}"
    if max_in_new_contour[1] > $ele + 1 && !$visited_before.include?(max_in_new_contour[0])
      puts "Found candidate to break dominance: #{max_in_new_contour}".yellow
      prominence_parent_candidate = climb(max_in_new_contour[0], 1)
      puts "Climbed up to #{prominence_parent_candidate}".yellow
      if prominence_parent_candidate[1] > peak[0].to_i
        key_col = $ele + 1
        prominence = peak[0].to_i - key_col
        puts "Prominence data of #{peak}:".light_green
        puts "Prominence parent: #{prominence_parent_candidate}".light_green
        puts "Key col: #{key_col}".light_green
        puts "Prominence: #{prominence}".light_green
        update_prominence(ARGV[0], prominence, prominence_parent_candidate[2])
      else
        puts "Not high enough"
      end
      exit
    else
      $contour = new_contour.keys
      puts "Continue spilling with #{$contour.size} positions"
      $visited += $contour
      puts "Total visited #{$visited.size}"
    end
  else
    puts "Spilled entirely above #{$ele}, total visited #{$visited.size}".light_green
    $ele -= 1
    $contour = [[peak[1], peak[2]]]
    $visited_before += $visited
    puts "$visited_before.size = #{$visited_before.size}"
    $visited = [[peak[1], peak[2]]]
  end
end