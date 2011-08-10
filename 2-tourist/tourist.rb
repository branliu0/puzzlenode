#!/usr/bin/env ruby
#
# http://puzzlenode.com/puzzles/3
#
# We can't use Dijkstra's here. When using Jennifer's cost function (shortest
# travel time), subpaths of a shortest path is not a shortest path. Meaning
# that if A-B-Z is a shortest path, then the subpath A-B is not guaranteed to
# be the optimal path from A to B. This must be the case for Dijkstra's to
# work, because it builds upon previous shortest paths.
#
# So, we must use DFS to search through all possible paths.
#
# Also, it's not necessary to actually store the time in a structured format.
# We can just translate the times to an integer that represents the number of
# minutes, which is much easier to manipulate

# Returns nil if there is no valid path to the end city
def best_flight(flights, best_decider, city, start_time, cur_time, acc_cost)
  if city == END_CITY
    return { start: start_time, stop: cur_time, cost: acc_cost }
  end

  possibles = flights[city].select{ |f| cur_time.nil? || f[:start] >= cur_time }.map do |flight|
    best_flight(flights, best_decider, flight[:to], start_time.nil? ? flight[:start] : start_time,
                flight[:stop], acc_cost + flight[:cost])
  end.compact
  return nil if possibles.empty?
  possibles.inject { |acc, obj| best_decider.call(acc, obj) }
end

def lowest_cost(flight1, flight2)
  flight1[:cost] < flight2[:cost] ? flight1 : flight2
end

def least_time(flight1, flight2)
  (flight1[:stop] - flight1[:start]) < (flight2[:stop] - flight2[:start]) ? flight1 : flight2
end

# Assumes input of HH:MM and outputs 60*HH + MM
class String
  def to_min
    60 * self[0..1].to_i + self[3..4].to_i
  end
end

class Integer
  def to_time
    sprintf("%02d:%02d", self / 60, self % 60)
  end
end

START_CITY = "A"
END_CITY = "Z"

if ARGV.length < 1
  $stderr.puts "Usage: ./tourist.rb [input-file]"
  exit 1
end

File.open(ARGV[0]) do |file|
  num_trips = file.gets.chomp.to_i
  num_trips.times do |trip_num|
    file.gets # Skip the first blank line
    flights = Hash.new{ |hash, key| hash[key] = [] }
    num_flights = file.gets.chomp.to_i
    # Collect up all the flight information
    num_flights.times do
      from, to, start, stop, cost = file.gets.chomp.split
      flights[from] << { to: to, start: start.to_min, stop: stop.to_min, cost: cost.to_f }
    end
    cheapest = best_flight(flights, method(:lowest_cost), START_CITY, nil, nil, 0)
    fastest = best_flight(flights, method(:least_time), START_CITY, nil, nil, 0)
    [cheapest, fastest].each do |a|
      puts [a[:start].to_time, a[:stop].to_time, a[:cost].round(2)].join(" ")
    end
    puts unless trip_num == num_trips - 1
  end
end
