#!/usr/bin/env ruby

require 'date'
# require 'Enumerable'
require 'optparse'
opt = OptionParser.new
option ={}

opt.on('-m [val]',Integer, 'description:m'){|v| option[:m] = v}
opt.on('-y [val]',Integer, 'description:y'){|v| option[:y] = v}

opt.parse(ARGV)

example_day = Date.today
now_hinichi = example_day.day
now_youbi =example_day.cwday

if option[:m] == nil
  now_month = example_day.month
elsif option[:m] < 1 || option[:m] > 12
  puts "無効です"
  now_month = example_day.month
else
  now_month = option[:m]
end

if option[:y] == nil
  now_year = example_day.year
elsif  option[:y] < 1970 || option[:y] > 2100
  puts "範囲外です"
  now_year = option[:y]
else
  now_year = option[:y]
end

lastday = Date.new(now_year,now_month,-1).day
write_date = Date.new(now_year,now_month,1).day
write_youbi = Date.new(now_year,now_month,1).cwday
first_cwday = Date.new(now_year,now_month,1).cwday

puts '      ' + now_year.to_s + '年' + now_month.to_s + '月'
puts  '日　月　火　水　木　金　土'


while write_date <= lastday

# 1日が何曜日かによって空白を変える
  if first_cwday != 7
    while first_cwday > 0
      print "　　"
      first_cwday -= 1
    end
  end
  if write_date > 9
  print "#{write_date}" + "　"
  else
    print " " +"#{write_date}" + "　"
  end
  write_date += 1;
  write_youbi += 1;
  if write_youbi %7 == 0
    puts "\n"
  end
end

