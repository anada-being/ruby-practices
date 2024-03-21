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
  end
end
