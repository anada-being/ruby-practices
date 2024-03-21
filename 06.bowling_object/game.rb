#!/usr/bin/env ruby
# frozen_string_literal: true

require './shot'
require './frame'

class Game
  def initialize(score)
    @frames = parse_frames(score)
  end

  private

  def parse_frames(score)
    marks = score.split(',')
    frames = []
    9.times do
      frames << if marks[0] == 'X'
                  Frame.new([marks.shift])
                else
                  Frame.new(marks.shift(2))
                end
    end
    frames << Frame.new(marks)
    frames
  end

  public

  def calc
    total_score = 0
    @frames.each_with_index do |frame, frame_count|
      total_score += frame.score
      next if frame.score != 10
      next if frame_count == 9

      next_frame = @frames[frame_count + 1]
      total_score += if frame.shots[0].strike? && frame_count == 8
                       next_frame.shots[0].point + next_frame.shots[1].point
                     elsif frame.shots[0].strike?
                       frame.strike(next_frame, @frames[frame_count + 2].shots)
                     else
                       frame.spare(next_frame.shots)
                     end
    end
    puts total_score
  end
end

score = ARGV[0]
game = Game.new(score)
game.calc
