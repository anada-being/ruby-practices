#!/usr/bin/env ruby

# frozen_string_literal: true

require 'date'
require 'optparse'

opt = OptionParser.new
option = {}

opt.on('-m [val]', Integer, 'description:m') { |v| option[:m] = v }
opt.on('-y [val]', Integer, 'description:y') { |v| option[:y] = v }

opt.parse(ARGV)

example_day = Date.today

new_month = if option[:m].nil?
              example_day.month
            elsif option[:m] < 1 || option[:m] > 12
              example_day.month
            else
              option[:m]
            end
new_year = if option[:y].nil?
             example_day.year
           elsif option[:y] < 1970 || option[:y] > 2100
             example_day.year
           else
             option[:y]
           end

last_day = Date.new(new_year, new_month, -1).day
write_date = Date.new(new_year, new_month, 1).day
write_youbi = Date.new(new_year, new_month, 1).cwday
first_cwday = Date.new(new_year, new_month, 1).cwday

puts "   #{new_month} #{new_year}"
puts 'Su Mo Tu We Th Fr Sa'

print '   ' * first_cwday if first_cwday != 7

(1..last_day).each do
  if write_date > 9
    print "#{write_date} "
  else
    print " #{write_date} "
  end
  write_date += 1
  write_youbi += 1
  write_youbi = write_youbi % 7
  puts "\n" if write_youbi.zero?
end
puts "\n"
