def sum(position1, position2)
  [(position1[0] + position2[0]).round(4), (position1[1] + position2[1]).round(4)]
end

# Return array of arrays
# Outer arrays is "by the radius"
# Inner array consists of positions on the given radius
def surrounding(position, radius)
  dlat = 0.0001
  dlng = 0.0001
  (1..radius).map do |r|
    (-r..r).map do |rlat|
      points = [sum(position, [dlat * rlat, dlng * (r - rlat.abs)])]
      if rlat.abs != r
        points += [sum(position, [dlat * rlat, dlng * (rlat.abs - r)])]
      end
      points
    end.flatten(1)
  end
end