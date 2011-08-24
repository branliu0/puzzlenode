#!/usr/bin/env ruby

GATES = /(N|O|A|X|0|1)/
BULB = "@"

def solve_gate circuit, row, col
  if circuit[row][col] == "0"
    return false
  elsif circuit[row][col] == "1"
    return true
  end

  gate = circuit[row][col]

  top_row = row
  top_row -= 1 until top_row == 0 || circuit[top_row - 1][col] != "|"
  top_col = circuit[top_row].rindex(GATES, col)
  top_gate = circuit[top_row][top_col]
  top_val = solve_gate circuit, top_row, top_col

  if gate != "N"
    bottom_row = row
    bottom_row += 1 until bottom_row == circuit.length - 1 || circuit[bottom_row + 1][col] != "|"
    bottom_col = circuit[bottom_row].rindex(GATES, col)
    bottom_gate = circuit[bottom_row][bottom_col]
    bottom_val = solve_gate circuit, bottom_row, bottom_col
  end

  val = case gate
  when "N"; !top_val
  when "O"; top_val || bottom_val
  when "A"; top_val && bottom_val
  when "X"; top_val ^ bottom_val
  else; fail
  end
  circuit[row][col+1] = val ? "1" : "0"
  val
end

def solve circuit
  bulb_row = nil
  circuit.each_with_index do |line, i|
    if line.include? BULB
      bulb_row = i
      break
    end
  end
  gate_col = circuit[bulb_row].rindex(GATES, circuit[bulb_row].index(BULB))
  val = solve_gate circuit, bulb_row, gate_col
  # puts circuit.join("\n")
  # puts circuit.length
  val
end

if ARGV.length < 1
  $stderr.puts "Usage: #{$0} [circuits.txt]"
  exit 1
end

File.open(ARGV[0]) do |file|
  while !file.eof?
    circuit = []
    while !file.eof? && (line = file.gets.chomp).length > 0
      circuit << line
    end
    puts (solve circuit) ? "on" : "off"
  end
end
