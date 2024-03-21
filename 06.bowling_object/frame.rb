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
    next_frame.shots[0].strike? ? 10 + after_next_shots[0].point : next_frame.score
  end

  def spare(next_shots)
    next_shots[0].point
  end
end
