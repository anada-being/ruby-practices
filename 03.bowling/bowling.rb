#!/usr/bin/env ruby

# frozen_string_literal: true

STRIKE = 10
SPARE = 10
DOUBLE = 20
LAST_FLAME = 9
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

point = 0
frames.each_with_index do |frame, index|
  next_frame = frames[index + 1]
  point += if frame[0] == STRIKE && index < LAST_FLAME
             if next_frame[0] == STRIKE
               DOUBLE + frames[index + 2][0]
             else
               STRIKE + next_frame.sum
             end
           elsif frame.sum == SPARE && index < LAST_FLAME
             SPARE + next_frame[0]
           else
             frame.sum
           end
end
puts point
