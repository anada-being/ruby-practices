# frozen_string_literal: true

require './shot'

class Frame
  attr_reader :shots

  def initialize(shots)
    @shots = shots.map { |shot| Shot.new(shot) }
  end

  def score
    @shots.map(&:point).sum
  end

  def strike(next_frame, after_next_shots)
    if next_frame.shots[0].mark != 'X'
      next_frame.score
    else
      10 + after_next_shots[0].point
    end
  end

  def spare(next_shots)
    next_shots[0].point
  end
end
