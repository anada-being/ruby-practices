# frozen_string_literal: true

require './shot'

class Frame
  attr_reader :shots

  def initialize(shots, frame_count)
    @shots = shots.map { |shot| Shot.new(shot) }
    @frame_count = frame_count
  end

  def score(frames)
    frame_score = sum_frame(@shots)
    return frame_score if frame_score != 10 || @frame_count == 10

    next_frame = @frame_count + 1
    frame_score + if @shots[0].strike? && @frame_count == 9
                    sum_frame(frames[@frame_count].shots[0, 2])
                  elsif @shots[0].strike?
                    strike(frames[@frame_count].shots, frames[next_frame])
                  else
                    spare(frames[@frame_count].shots)
                  end
  end

  private

  def sum_frame(shots)
    shots.map(&:point).sum
  end

  def strike(next_shots, after_next_shots)
    next_shots[0].strike? ? 10 + after_next_shots[0].point : sum_frame(next_shots)
  end

  def spare(next_shots)
    next_shots[0].point
  end
end
