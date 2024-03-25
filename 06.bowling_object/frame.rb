# frozen_string_literal: true

require './shot'

class Frame
  attr_reader :shots, :is_strike

  def initialize(shots, frame_count, is_strike)
    @shots = shots.map { |shot| Shot.new(shot) }
    @frame_count = frame_count
    @is_strike = is_strike
  end

  def score(frames)
    frame_score = @shots.sum(&:point)
    return frame_score if frame_score != 10 || @frame_count == 10

    after_next_frame = @frame_count + 1
    bonus_score = if @is_strike
                    @frame_count == 9 ? frames[@frame_count].shots[0, 2].sum(&:point) : strike(frames[@frame_count], frames[after_next_frame])
                  else
                    spare(frames[@frame_count].shots)
                  end
    frame_score + bonus_score
  end

  private

  def strike(next_shots, after_next_shots)
    next_shots.is_strike ? 10 + after_next_shots.shots[0].point : next_shots.shots.sum(&:point)
  end

  def spare(next_shots)
    next_shots[0].point
  end
end
