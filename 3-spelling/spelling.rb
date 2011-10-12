#!/usr/bin/env ruby

# Notes:
# This is the classic longest common subsequence problem.
# The recurrence looks like this:
# Suppose we have strings a and b of length |N| and |M|, respectively, and
# we want to find the length of their longest common subsequence. Then define
# f(i,j) := length of the longest common subsequence of a[0..i] and b[0..j]
# f(i,j) = { 0                          if i == 0 OR j == 0
#            f(i-1, j-1) + 1            if a[i] == b[j]
#            max(f(i, j-1), f(i-1, j)   otherwise           }
# Our desired solution is f(|N|, |M|)
# If we want to solve this iteratively, we should just iterate normally
# through each row of the |N| by |M| matrix that represents the solution space
# of f(i,j).
#
# But actually we only need to store the previous row of the matrix at any
# one time!
# So this algorithm takes quadratic time and linear space!

# Returns the length of the Longest Common Subsequence of the two provided
# strings
def lcs(a, b)
  old = Array.new(b.length + 1, 0)
  (1..a.length).each do |i| # Skip the first row, which is all zeroes anyway
    memo = Array.new
    (0..b.length).each do |j|
      if j == 0
        memo[j] = 0
      elsif a[i - 1] == b[j - 1]
        memo[j] = old[j-1] + 1
      else
        memo[j] = [memo[j-1], old[j]].max
      end
    end
    old = memo
    # p memo
  end
  # puts old[-1]
  old[-1]
end

### MAIN ###

if ARGV.length < 1
  $stderr.puts "Usage: ./spelling.rb input.txt"
  exit 1
end

File.open(ARGV[0]) do |file|
  num_words = file.gets.chomp.to_i
  num_words.times do
    file.gets # Skip the blank line
    word = file.gets.chomp
    opt1 = file.gets.chomp
    opt2 = file.gets.chomp
    puts lcs(word, opt1) > lcs(word, opt2) ? opt1 : opt2
  end
end
