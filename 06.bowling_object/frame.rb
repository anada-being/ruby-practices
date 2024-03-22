# frozen_string_literal: true

require './shot'

class Frame
  attr_reader :shots

  def initialize(shots)
    @shots = shots.map { |shot| Shot.new(shot) }
  end

  def score(scores, frame_count)
    frame_score = sum_frame(@shots)
    return frame_score if frame_score != 10 || frame_count == 9

    next_frame = scores[frame_count + 1]
    frame_score + if @shots[0].strike? && frame_count == 8
                    sum_frame(next_frame.shots[0, 2])
                  elsif @shots[0].strike?
                    strike(next_frame.shots, scores[frame_count + 2].shots)
                  else
                    spare(next_frame.shots)
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
