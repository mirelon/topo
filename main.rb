require_relative 'hill_climbing.rb'
require 'byebug'

init_pos = (ARGV[0] || "48.5700,17.8300").split(",").map(&:to_f)
# puts highest_neighbor(init_pos, 1).inspect
puts "Peak id #{climb(init_pos, 1)}"
url = $db.get_first_value('select "https://www.google.com/maps/dir/" || group_concat((lat || "," || lng), "/") from peaks;')
