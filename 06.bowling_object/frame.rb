# frozen_string_literal: true

require './shot'

class Frame
  attr_reader :shots

  def initialize(shots, frame_number)
    @shots = shots
    @frame_number = frame_number
  end

  def strike? = @shots[0].strike?
  def points = @shots.map(&:point)

  def score(frames)
    return points.sum if points.sum != 10 || @frame_number == 9

    next_frame = frames[@frame_number + 1]
    after_next_frame = frames[@frame_number + 2]
    bonus_score = strike? ? calc_strike(next_frame, after_next_frame) : next_frame.points[0]
    points.sum + bonus_score
  end

  private

  def calc_strike(next_frame, after_next_frame)
    return next_frame.points[0, 2].sum if @frame_number == 8

    next_frame.strike? ? 10 + after_next_frame.points[0] : next_frame.points.sum
  end
end
