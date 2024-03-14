#!/usr/bin/env ruby
# frozen_string_literal: true

require './shot'
require './frame'

class Game
  def initialize(score)
    @frames = parse_frames(score)
  end

  def parse_frames(score)
    frames_mark = score.split(',')
    frames = []
    9.times do
      frames << if frames_mark[0] == 'X'
                  Frame.new(frames_mark.shift)
                else
                  Frame.new(frames_mark.shift, frames_mark.shift)
                end
    end
    frames << Frame.new(frames_mark[0], frames_mark[1], frames_mark[2])
    frames
  end

  def calc
    total_score = 0
    @frames.each_with_index do |frame, count|
      total_score += frame.score
      next if frame.score != 10

      total_score += if frame.first_shot.mark == 'X'
                       strike(count)
                     else
                       spare(count)
                     end
    end
    puts total_score
  end

  def strike(count)
    return 0 if count > 8

    next_frame = @frames[count + 1]
    if count == 8 || next_frame.first_shot.mark != 'X'
      Shot.new(next_frame.first_shot.mark).score + Shot.new(next_frame.second_shot.mark).score
    else
      after_next_shot = @frames[count + 2].first_shot.mark
      10 + Shot.new(after_next_shot).score
    end
  end

  def spare(count)
    return 0 if count > 8

    Shot.new(@frames[count + 1].first_shot.mark).score
  end
end

score = ARGV[0]
game = Game.new(score)
game.calc
