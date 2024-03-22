#!/usr/bin/env ruby
# frozen_string_literal: true

require './shot'
require './frame'

class Game
  def initialize(score)
    @frames = parse_frames(score)
  end

  def calc
    total_score = 0
    @frames.each_with_index do |frame, frame_count|
      total_score += frame.score(@frames, frame_count)
    end
    total_score
  end

  private

  def parse_frames(score)
    marks = score.split(',')
    frames = (1..9).map { marks[0] == 'X' ? Frame.new([marks.shift]) : Frame.new(marks.shift(2)) }
    [*frames, Frame.new(marks)]
  end
end

score = ARGV[0]
game = Game.new(score)
puts game.calc
