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
    marks = score.split(',')
    frames = (1..9).map do |i|
      if strike?(marks[0])
        marks.shift
        Frame.new(['10'], i, true)
      else
        Frame.new(marks.shift(2), i, false)
      end
    end
    marks.map! { |mark| strike?(mark)? '10' : mark }
    [*frames, Frame.new(marks, 10, false)]
  end

  def strike?(mark)
    mark == 'X'
  end
end

score = ARGV[0]
game = Game.new(score)
puts game.calc_total
