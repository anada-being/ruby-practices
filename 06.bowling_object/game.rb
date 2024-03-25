#!/usr/bin/env ruby
# frozen_string_literal: true

require './shot'
require './frame'

class Game
  def initialize(score)
    @frames = parse_frames(score)
  end

  def calc
    @frames.each.sum do |frame|
      frame.score(@frames)
    end
  end

  private

  def parse_frames(score)
    marks = score.split(',')
    frames = (1..9).map { |i| Shot.new(marks[0]).strike? ? Frame.new([marks.shift], i) : Frame.new(marks.shift(2), i) }
    [*frames, Frame.new(marks, 10)]
  end
end

score = ARGV[0]
game = Game.new(score)
puts game.calc
