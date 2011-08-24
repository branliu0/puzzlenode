#!/usr/bin/env ruby

def flow cave, row, col, water
  if water <= 0 || cave[row][col] =~ /[#|~]/
    return water
  end

  cave[row][col] = "~"
  water -= 1

  # first flow down, then try to flow right
  water = flow cave, row + 1, col, water
  water = flow cave, row, col + 1, water
  water
end

def count cave
  count = Array.new(cave[0].length, 0)
  cave.each do |row|
    row.chars.with_index do |char, i|
      next unless count[i].is_a? Integer
      if char == "~"
        count[i] += 1
      elsif char == " " && count[i] > 0
        count[i] = "~"
      end
    end
  end
  count
end

if ARGV.length < 1
  $stderr.puts "Usage: #{$0} [cave.txt]"
  exit 1
end

File.open(ARGV[0]) do |file|
  cave = []
  water = file.gets.chomp.to_i
  file.gets
  while !file.eof?
    cave << file.gets.chomp
  end
  start_row = cave.each_with_index { |row, i| break i if row.include? "~" }
  flow cave, start_row, 1, water - 1
  count = count cave
  puts count.join(" ")
end
