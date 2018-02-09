require_relative 'surrounding.rb'
require_relative 'elevations.rb'
require_relative 'peaks.rb'
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
      puts "Found candidate to break dominance: #{max_in_new_contour}"
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