#!/usr/bin/env ruby

if ARGV.length < 1
  $stderr.puts "Usage: ./robots.rb [input-file]"
  exit 1
end

File.open(ARGV[0]) do |file|
  while not file.eof?
    top = file.gets.chomp
    robot = file.gets.chomp
    bottom = file.gets.chomp
    file.gets # Skip a line
    r_index = robot.index("X")
    # Assuming that top shoots every odd time unit, bottom shoots every even
    # unit
    west, east = 0, 0 # Damage counters
    top.chars.with_index do |char, index|
      # We only care about the even time units
      if (r_index - index) % 2 != 0
        next
      end
      if char == "|"
        if index == r_index
          west += 1
          east += 1
        elsif index < r_index
          west += 1
        else
          east += 1
        end
      end
    end
    bottom.chars.with_index do |char, index|
      # We only care about the odd time units
      if (r_index - index) % 2 != 1
        next
      end
      if char == "|"
        if index == r_index
          west += 1
          east += 1
        elsif index < r_index
          west += 1
        else
          east += 1
        end
      end
    end
    puts west <= east ? "GO WEST" : "GO EAST"
  end
end
