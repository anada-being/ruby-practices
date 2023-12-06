#!/usr/bin/env ruby

# frozen_string_literal: true

score = ARGV[0]
scores = score.split(/,/)
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  frames << s
end

point = 0
frames.each_with_index do |frame, number|
  point += if frame[0] == 10 && number < 9 && !frames[number + 1].nil?
             if frames[number + 1][0] == 10
               20 + frames[number + 2][0]
             elsif number < 9 && frame[0] == 10
               10 + frames[number + 1].sum
             end
           elsif number < 9 && frame.sum == 10
             frames[number + 1][0] + 10
           else
             frame.sum
           end
end
puts point
