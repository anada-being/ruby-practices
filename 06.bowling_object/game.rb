#!/usr/bin/env ruby
# frozen_string_literal: true

require './shot'
require './frame'

class Game
  def initialize(score)
    @frames = parse_frames(score)
  end

  def calc_total
    @frames.sum do |frame|
      frame.score(@frames)
    end
  end

  private

  def parse_frames(score)
    shots = score.split(',').map { |mark| Shot.new(mark) }
    frames = (0..8).map do |i|
      shots[0].strike? ? Frame.new([shots.shift], i) : Frame.new(shots.shift(2), i)
    end
    [*frames, Frame.new(shots, 9)]
  end
end

score = ARGV[0]
game = Game.new(score)
puts game.calc_total
