#!/usr/bin/env ruby
# frozen_string_literal: true

require './shot'
require './frame'

class Game
  def initialize(score)
    @frames = parse_frames(score)
  end

  def calc_total
    @frames.each.sum do |frame|
      frame.score(@frames)
    end
  end

  private

  def parse_frames(score)
    marks = score.split(',').map { |mark| Shot.new(mark) }
    frames = (0..8).map do |i|
      if marks[0].strike?
        Frame.new([marks.shift], i)
      else
        Frame.new(marks.shift(2), i)
      end
    end
    [*frames, Frame.new(marks, 9)]
  end
end

score = ARGV[0]
game = Game.new(score)
puts game.calc_total
