#!/usr/bin/env ruby

require 'pp'

DIRS = [
  [-1, 0], # Facing upward
  [-1, 1],
  [0, 1],
  [1, 1],
  [1, 0],
  [1, -1],
  [0, -1],
  [-1, -1]
]

$t_dir = 0

def print_board
  puts $board.map{ |row| row.join(" ") }.join("\n")
end

def eval_cmd(cmd)
  case cmd
  when /RT (\d+)/
    $t_dir += $1.to_i/45
    $t_dir %= DIRS.length
  when /LT (\d+)/
    $t_dir -= $1.to_i/45
    $t_dir %= DIRS.length
  when /FD (\d+)/
    dir = DIRS[$t_dir]
    dist = $1.to_i
    dist.times do |i|
      $board[$t_row + (i+1) * dir[0]][$t_col + (i+1) * dir[1]] = "X"
    end
    $t_row += dist * dir[0]
    $t_col += dist * dir[1]
  when /BK (\d+)/
    dir = DIRS[$t_dir]
    dist = $1.to_i
    dist.times do |i|
      $board[$t_row - (i+1) * dir[0]][$t_col - (i+1) * dir[1]] = "X"
    end
    $t_row -= dist * dir[0]
    $t_col -= dist * dir[1]
  else
    raise "Invalid command"
  end
end

if ARGV.length < 1
  $stderr.puts "Usage: ./turtle.rb [commands.logo]"
  exit 1
end

File.open(ARGV[0]) do |file|
  board_size = file.gets.chomp.to_i
  $board = Array.new(board_size) { Array.new(board_size, ".") }
  $t_row = $t_col = board_size/2
  $board[$t_row][$t_col] = "X"
  file.gets # Skip a line

  while ! file.eof?
    cmd = file.gets.chomp
    if cmd =~ /REPEAT (\d+) \[ (.+) \]/
      repeats = $1.to_i
      cmds = $2.scan(/\w+ \w+/)
      repeats.times do |i|
        cmds.each { |cmd| eval_cmd(cmd) }
      end
    else
      eval_cmd(cmd)
    end
  end
end

print_board
