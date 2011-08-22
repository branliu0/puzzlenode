#!/usr/bin/env ruby

require 'json'
require 'date'
require 'pp'

YR_START = Date.strptime("2011-01-01")
YR_END = Date.strptime("2011-12-31")

if ARGV.length < 2
  $stderr.puts "Usage: ./hawaii.rb [vacation-info.json] [input-file]"
  exit 1
end

# Load in JSON information for all the rentals
rentals = []
File.open(ARGV[0]) do |file|
  json = JSON.load(file.gets.chomp)
  json.each do |place|
    rental = {}
    rental[:name] = place["name"]
    if place["rate"]
      rental[:seasons] = [{ :range => (YR_START..YR_END), :rate => place["rate"][1..-1].to_i }]
    else
      rental[:seasons] = []
      place["seasons"].map{ |s| s.values.first }.each do |season|
        rate = season["rate"][1..-1].to_i
        season_start = Date.strptime(season["start"], "%m-%d")
        season_end = Date.strptime(season["end"], "%m-%d")
        if season_end < season_start # Split up seasons that wrap around into two
          rental[:seasons] << { :range => (YR_START..season_end), :rate => rate }
          rental[:seasons] << { :range => (season_start..YR_END), :rate => rate }
        else
          rental[:seasons] << { :range => (season_start..season_end), :rate => rate }
        end
      end
      # rental[:seasons].sort! { |a,b| a[:range].begin <=> b[:range].begin }
    end
    rental[:cleaning_fee] = place["cleaning fee"][1..-1].to_i if place["cleaning fee"]
    rentals << rental
  end
  # pp rentals
end

# Read in the vacation dates
v_range = nil
File.open(ARGV[1]) do |file|
  v_start, v_end = file.gets.chomp.split('-').map{ |d| Date.strptime(d.strip, "%Y/%m/%d") }
  v_range = (v_start...v_end)
end

# Calculate the rates for each rental
rentals.each do |rental|
  cost = 0
  v_range.each do |day|
    season = rental[:seasons].select do |season|
      season[:range].include? day
    end.first
    cost += season[:rate]
    # puts "#{day}: Cost $#{season[:rate]} => #{cost} for #{season}"
  end
  if rental[:cleaning_fee]
    cost += rental[:cleaning_fee]
    # puts "Added cleaning fee of $#{rental[:cleaning_fee]} => #{cost}"
  end
  cost *= 1.0411416
  # puts "Added tax => #{cost}"
  puts "#{rental[:name]}: $#{sprintf("%.2f", cost.round(2))}"
end

