#!/usr/bin/env ruby

# frozen_string_literal: true

argument_scores = ARGV[0]
scores = argument_scores.split(/,/)
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a

STRIKE = 10
SPARE = 10
point = 0
frames.each_with_index do |frame, index|
  next_frame = frames[index + 1]
  point += if frame[0] == STRIKE && index < 9
             if next_frame[0] == STRIKE
               20 + frames[index + 2][0]
             else
               10 + next_frame.sum
             end
           elsif frame.sum == SPARE && index < 9
             10 + next_frame[0]
           else
             frame.sum
           end
end
puts point

