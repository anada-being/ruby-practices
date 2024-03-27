# frozen_string_literal: true

require './shot'

class Frame
  attr_reader :shots

  def initialize(shots, frame_number)
    @shots = shots
    @frame_number = frame_number
  end

  def score(frames)
    frame_score = @shots.sum(&:point)
    return frame_score if frame_score != 10 || @frame_number == 9

    next_frame = frames[@frame_number + 1]
    after_next_frame = frames[@frame_number + 2]
    bonus_score = if @shots[0].strike?
                    calc_strike(next_frame, after_next_frame)
                  else
                    calc_spare(next_frame.shots)
                  end
    frame_score + bonus_score
  end

  private

  def calc_strike(next_frame, after_next_frame)
    return next_frame.shots[0, 2].sum(&:point) if @frame_number == 8

    next_frame.shots[0].strike? ? 10 + after_next_frame.shots[0].point : next_frame.shots.sum(&:point)
  end

  def calc_spare(next_shots)
    next_shots[0].point
  end
end
