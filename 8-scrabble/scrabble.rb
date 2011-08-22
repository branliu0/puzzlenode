#!/usr/bin/env ruby

require 'json'
require 'pp'

if ARGV.length < 1
  $stderr.puts "Usage: ./scrabble.rb [input.json]"
  exit 1
end

# Load Scrabble information
# Load the board
scrabble = JSON.load(File.readlines(ARGV[0]).join)
board = []
scrabble["board"].each do |row|
  board << row.split.map(&:to_i)
end
board_rows = board.length
board_cols = board[0].length

# Load the tiles
tiles = Hash.new { |hash, key| hash[key] = { :count => 0 }}
scrabble["tiles"].each do |tile|
  tiles[tile[0]][:value] = tile[1..-1].to_i
  tiles[tile[0]][:count] += 1
end

# Remove words from the dictionary that cannot be formed
scrabble["dictionary"].delete_if do |word|
  tile_count = Hash.new { |hash, key| hash[key] = 0 } # Count of the tiles used by this word
  # Select the tiles that don't fit
  word.chars.select do |c|
    if ! tiles.has_key? c # Either we don't have the tile at all
      true
    else
      tile_count[c] += 1
      tile_count[c] > tiles[c][:count] # Or there aren't enough of the tiles
    end
  end.length > 0
end

# Try each word, and save the best
best_dir = nil
best_val = 0
best_word = nil
best_row, best_col = nil, nil

scrabble["dictionary"].each do |word|
  # first try going from left to right
  (0...board_rows).each do |row|
    (0...(board_cols - word.length + 1)).each do |col|
      value = 0
      word.chars.with_index do |c, i|
        value += board[row][col+i] * tiles[c][:value]
      end
      if value > best_val
        best_dir = :right
        best_val = value
        best_word = word
        best_row, best_col = row, col
      end
    end
  end
  # Now try going from up to down
  (0...(board_rows - word.length + 1)).each do |row|
    (0...board_cols).each do |col|
      value = 0
      word.chars.with_index do |c, i|
        value += board[row+i][col] * tiles[c][:value]
      end
      if value > best_val
        best_dir = :down
        best_val = value
        best_word = word
        best_row, best_col = row, col
      end
    end
  end
end

# Might as well clobber the board, since we don't need it anymore
best_word.chars.with_index do |c, i|
  case best_dir
  when :right; board[best_row][best_col+i] = c
  when :down; board[best_row+i][best_col] = c
  end
end

print board.map{ |row| row.join(" ")}.join("\n")
