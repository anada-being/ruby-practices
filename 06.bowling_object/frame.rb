# frozen_string_literal: true

require './shot'

class Frame
  attr_reader :shots, :is_strike, :points

  def initialize(shots, frame_number)
    @shots = shots
    @frame_number = frame_number
    @is_strike = shots[0].strike?
    @points = shots.map(&:point)
  end

  def score(frames)
    frame_score = @points.sum
    return frame_score if frame_score != 10 || @frame_number == 9

    next_frame = frames[@frame_number + 1]
    after_next_frame = frames[@frame_number + 2]
    bonus_score = if @is_strike
                    calc_strike(next_frame, after_next_frame)
                  else
                    next_frame.points[0]
                  end
    frame_score + bonus_score
  end

  private

  def calc_strike(next_frame, after_next_frame)
    return next_frame.points[0, 2].sum if @frame_number == 8

    next_frame.is_strike ? 10 + after_next_frame.points[0] : next_frame.points.sum
  end
end
