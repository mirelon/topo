require_relative 'hill_climbing.rb'
require 'byebug'

init_pos = [48.5850,17.8500]
# puts highest_neighbor(init_pos, 1).inspect
climb(init_pos, 1)
